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
            answers = [] // reset answers for new question
        } catch {
            errorMessage = "Failed to load question: \(error.localizedDescription)"
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
                let answerVotes = try await cloudKit.fetchVotes(forsessionQuestion: answer.sessionQuestionID)
                let votesForThisAnswer = answerVotes.filter { $0.answerID == answer.id }
                voteCounts[answer.playerID, default: 0] += votesForThisAnswer.count
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
