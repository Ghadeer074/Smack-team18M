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
            
            // Add host as player
            let host = try await cloudKit.addPlayer(
                sessionID: newsession.id,
                deviceID: deviceManager.deviceID,
                username: username,
                isHost: true
            )
            
            players = [host]
            gameState = .lobby
            
            // Start polling for new players
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
            
            // Load questions for the game
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
            
            // Check if session is full
            let existingPlayers = try await cloudKit.fetchPlayers(forsession: foundsession.id)
            guard existingPlayers.count < foundsession.maxPlayers else {
                errorMessage = "session is full"
                isLoading = false
                return
            }
            
            // Join as player
            let player = try await cloudKit.addPlayer(
                sessionID: foundsession.id,
                deviceID: deviceManager.deviceID,
                username: username
            )
            
            session = foundsession
            players = existingPlayers + [player]
            gameState = .lobby
            
            // Start polling for updates
            startPlayerPolling()
            
        } catch {
            errorMessage = "Failed to join: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func leavesession() {
        session = nil
        players = []
        gameState = .lobby
        stopPlayerPolling()
    }
    
    // MARK: - Game Logic
    
    private func loadQuestions() async {
        guard let session = session else { return }
        
        do {
            let unansweredQuestions = try await cloudKit.fetchUnansweredQuestions(forSession: session.id)
            
            // if no unanswered questions exist yet, fetch free questions and create them
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
        } catch {
            errorMessage = "Failed to load question: \(error.localizedDescription)"
        }
    }
    
    
    
    func submitVote(for playerID: UUID) async {
        guard let session = session,
              let currentsessionQuestion = sessionQuestions.first(where: { $0.roundNumber == session.roundCount + 1 }),
              let currentPlayer = players.first(where: { $0.deviceID == deviceManager.deviceID }) else {
            return
        }
        
        do {
            let vote = try await cloudKit.submitVote(
                sessionQuestionID: currentsessionQuestion.id,
                voterID: currentPlayer.id,
                votedForID: playerID
            )
            
            votes.append(vote)
            
        } catch {
            errorMessage = "Failed to submit vote: \(error.localizedDescription)"
        }
    }
    
    func calculateWinner() async -> PlayerModel? {
        var voteCounts: [UUID: Int] = [:]
        
        do {
            for player in players {
                let votes = try await cloudKit.fetchVotes(forPlayer: player.id)
                voteCounts[player.id] = votes.count
            }
            
            return players.max(by: {
                (voteCounts[$0.id] ?? 0) < (voteCounts[$1.id] ?? 0)
            })
            
        } catch {
            errorMessage = "Failed to calculate winner: \(error.localizedDescription)"
            return nil
        }
    }
    
    func loadVotes(for sessionQuestionID: UUID) async {
        do {
            votes = try await cloudKit.fetchVotes(forsessionQuestion: sessionQuestionID)
        } catch {
            errorMessage = "Failed to load votes: \(error.localizedDescription)"
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
    
    // Helpers
  
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
