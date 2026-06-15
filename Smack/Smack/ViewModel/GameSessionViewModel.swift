//
//  GamesessionViewModel.swift
//  Smack
//  Created by Ghadeer Fallatah on 25/11/1447 AH.
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
class GamesessionViewModel: ObservableObject {
    @Published var session: sessionModel?
    @Published var players: [PlayerModel] = []
    @Published var currentQuestion: QuestionModel?
    @Published var sessionQuestions: [sessionQuestionModel] = []
    @Published var username: String = ""
    @Published var votes: [VoteModel] = []
    @Published var answers: [AnswerModel] = []
    @Published var gameState: GameState = .lobby
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let cloudKit = CloudKitManager.shared
    private let deviceManager = DeviceManager.shared
    private var updateTimer: Timer?
    
    enum GameState {
        case lobby
        case answering
        case voting
        case results
        case ended
    }
    
    // MARK: - Host Functions
    
    func createsession(maxPlayers: Int = 8) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let code = generatorCode()
            let newsession = try await cloudKit.createsession(joinCode: code, maxPlayers: maxPlayers)
            session = newsession
            
            // ✅ save code so we can restore session if app is killed
            UserDefaults.standard.set(code, forKey: "activeSessionCode")
            
            let host = try await cloudKit.addPlayer(
                sessionID: newsession.id,
                deviceID: deviceManager.deviceID,
                username: username,
                isHost: true
            )
            
            players = [host]
            gameState = .lobby
            startPlayerPolling()
            
        } catch {
            errorMessage = "Failed to create session: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func startGame() async {
        guard let session = session else { return }
        isLoading = true
        
        do {
            try await cloudKit.updatesessionStatus(sessionID: session.id, status: "playing")
            await loadQuestions()
            gameState = .answering
            
        } catch {
            errorMessage = "Failed to start game: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func endGame() async {
        guard let session = session else { return }
        
        do {
            try await cloudKit.updatesessionStatus(sessionID: session.id, status: "ended")
            gameState = .ended
            stopPlayerPolling()
            // ✅ clear saved session code
            UserDefaults.standard.removeObject(forKey: "activeSessionCode")
        } catch {
            errorMessage = "Failed to end game: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Player Functions
    
    func joinsession(withCode code: String, username: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let foundsession = try await cloudKit.fetchsession(byJoinCode: code.uppercased()) else {
                errorMessage = "session not found"
                isLoading = false
                return
            }
            
            guard foundsession.status == "waiting" else {
                errorMessage = "Game already started"
                isLoading = false
                return
            }
            
            let existingPlayers = try await cloudKit.fetchPlayers(forsession: foundsession.id)
            guard existingPlayers.count < foundsession.maxPlayers else {
                errorMessage = "session is full"
                isLoading = false
                return
            }
            
            let player = try await cloudKit.addPlayer(
                sessionID: foundsession.id,
                deviceID: deviceManager.deviceID,
                username: username
            )
            
            // ✅ save code for session restore
            UserDefaults.standard.set(code.uppercased(), forKey: "activeSessionCode")
            
            session = foundsession
            players = existingPlayers + [player]
            gameState = .lobby
            startPlayerPolling()
            
        } catch {
            errorMessage = "Failed to join: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func leavesession() {
        session = nil
        players = []
        answers = []
        votes = []
        gameState = .lobby
        stopPlayerPolling()
        // ✅ clear saved session code
        UserDefaults.standard.removeObject(forKey: "activeSessionCode")
    }
    
    // ✅ NEW: restore session on app relaunch
    func restoreSession() async {
        guard let savedCode = UserDefaults.standard.string(forKey: "activeSessionCode") else { return }
        
        do {
            guard let foundSession = try await cloudKit.fetchsession(byJoinCode: savedCode) else {
                UserDefaults.standard.removeObject(forKey: "activeSessionCode")
                return
            }
            
            guard foundSession.status != "ended" else {
                UserDefaults.standard.removeObject(forKey: "activeSessionCode")
                return
            }
            
            session = foundSession
            players = try await cloudKit.fetchPlayers(forsession: foundSession.id)
            sessionQuestions = try await cloudKit.fetchUnansweredQuestions(forSession: foundSession.id)
            gameState = foundSession.status == "waiting" ? .lobby : .answering
            startPlayerPolling()
            
        } catch {
            errorMessage = "Failed to restore session: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Role Selection
    
    // ✅ NEW: select role with locking logic
    func selectRole(_ role: String) async {
        guard let session = session,
              let currentPlayer = currentPlayer else { return }
        
        do {
            if role == "answerer" {
                let answererCount = try await cloudKit.countAnswerers(forSession: session.id)
                if answererCount >= 2 {
                    errorMessage = "Answerer slots are full, you will be a voter"
                    try await cloudKit.updatePlayerRole(playerID: currentPlayer.id, role: "voter")
                    return
                }
            }
            try await cloudKit.updatePlayerRole(playerID: currentPlayer.id, role: role)
            await refreshPlayers()
        } catch {
            errorMessage = "Failed to select role: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Game Logic
    
    private func loadQuestions() async {
        guard let session = session else { return }
        
        do {
            let unansweredQuestions = try await cloudKit.fetchUnansweredQuestions(forSession: session.id)
            
            if unansweredQuestions.isEmpty {
                let allQuestions = try await cloudKit.fetchFreeQuestions()
                let selectedQuestions = allQuestions.shuffled().prefix(10)
                
                for (index, question) in selectedQuestions.enumerated() {
                    let sessionQuestion = sessionQuestionModel(
                        sessionID: session.id,
                        questionID: question.id,
                        roundNumber: index + 1
                    )
                    let saved = try await cloudKit.save(sessionQuestion)
                    sessionQuestions.append(saved)
                }
            } else {
                sessionQuestions = unansweredQuestions
            }
            
            if let firstQuestion = sessionQuestions.first {
                await loadQuestion(sessionQuestionID: firstQuestion.id)
            }
            
        } catch {
            errorMessage = "Failed to load questions: \(error.localizedDescription)"
        }
    }
    
    private func loadQuestion(sessionQuestionID: UUID) async {
        guard let sessionQuestion = sessionQuestions.first(where: { $0.id == sessionQuestionID }) else {
            return
        }
        
        do {
            let predicate = NSPredicate(format: "id == %@", sessionQuestion.questionID.uuidString)
            let questions: [QuestionModel] = try await cloudKit.fetch(recordType: "Question", predicate: predicate)
            currentQuestion = questions.first
            answers = []
        } catch {
            errorMessage = "Failed to load question: \(error.localizedDescription)"
        }
    }
    
    // ✅ NEW: end round, mark question answered, increment round count
    func endRound() async {
        guard let session = session,
              let currentSessionQuestion = sessionQuestions.first(where: {
                  $0.roundNumber == session.roundCount + 1
              }) else { return }
        
        do {
            try await cloudKit.markQuestionAnswered(sessionQuestionID: currentSessionQuestion.id)
            try await cloudKit.incrementRoundCount(sessionID: session.id)
            self.session?.roundCount += 1
            answers = []
            votes = []
            
            // check if game is over based on session's maxAnswerers
            if let updatedSession = self.session,
               updatedSession.roundCount >= (updatedSession.maxAnswerers ?? 4) {
                await endGame()
            } else {
                await loadQuestions()
            }
        } catch {
            errorMessage = "Failed to end round: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Answer Functions
    
    func submitAnswer(content: String) async {
        guard let currentPlayer = currentPlayer,
              let currentSessionQuestion = sessionQuestions.first(where: {
                  $0.roundNumber == (session?.roundCount ?? 0) + 1
              }) else { return }
        
        do {
            let answer = try await cloudKit.submitAnswer(
                sessionQuestionID: currentSessionQuestion.id,
                playerID: currentPlayer.id,
                content: content
            )
            answers.append(answer)
            gameState = .voting
            
        } catch {
            errorMessage = "Failed to submit answer: \(error.localizedDescription)"
        }
    }
    
    func loadAnswers(for sessionQuestionID: UUID) async {
        do {
            answers = try await cloudKit.fetchAnswers(forSessionQuestion: sessionQuestionID)
        } catch {
            errorMessage = "Failed to load answers: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Vote Functions
    
    func submitVote(forAnswer answerID: UUID) async {
        guard let currentPlayer = currentPlayer,
              let currentSessionQuestion = sessionQuestions.first(where: {
                  $0.roundNumber == (session?.roundCount ?? 0) + 1
              }) else { return }
        
        do {
            let vote = try await cloudKit.submitVote(
                sessionQuestionID: currentSessionQuestion.id,
                voterID: currentPlayer.id,
                answerID: answerID
            )
            votes.append(vote)
            
        } catch {
            errorMessage = "Failed to submit vote: \(error.localizedDescription)"
        }
    }
    
    func loadVotes(for sessionQuestionID: UUID) async {
        do {
            votes = try await cloudKit.fetchVotes(forsessionQuestion: sessionQuestionID)
        } catch {
            errorMessage = "Failed to load votes: \(error.localizedDescription)"
        }
    }
    
    func calculateWinner() async -> PlayerModel? {
        var voteCounts: [UUID: Int] = [:]
        
        do {
            for answer in answers {
                let answerVotes = try await cloudKit.fetchVotes(forAnswer: answer.id)
                voteCounts[answer.playerID, default: 0] += answerVotes.count
            }
            
            return players.max(by: {
                (voteCounts[$0.id] ?? 0) < (voteCounts[$1.id] ?? 0)
            })
            
        } catch {
            errorMessage = "Failed to calculate winner: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Polling
    
    private func startPlayerPolling() {
        stopPlayerPolling()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshPlayers()
            }
        }
    }
    
    private func stopPlayerPolling() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func refreshPlayers() async {
        guard let session = session else { return }
        
        do {
            players = try await cloudKit.fetchPlayers(forsession: session.id)
        } catch {
            print("Failed to refresh players: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Computed Properties
    
    var currentPlayer: PlayerModel? {
        players.first(where: { $0.deviceID == deviceManager.deviceID })
    }
    
    var isHost: Bool {
        currentPlayer?.isHost ?? false
    }
    
    var canStartGame: Bool {
        isHost && players.count >= 2 && gameState == .lobby
    }
    
    var leaderboard: [PlayerModel] {
        players.sorted { $0.points > $1.points }
    }
}
