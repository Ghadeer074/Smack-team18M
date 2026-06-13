//
//  GameSessionViewModel.swift
//  Smack
//  Created by Ghadeer Fallatah on 25/11/1447 AH.
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
class GameSessionViewModel: ObservableObject {
    @Published var session: SessionModel?
    @Published var players: [PlayerModel] = []
    @Published var currentQuestion: QuestionModel?
    @Published var sessionQuestions: [SessionQuestionModel] = []
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
    
    func createSession(maxPlayers: Int = 8) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let code = generatorCode()
            let newSession = try await cloudKit.createSession(joinCode: code, maxPlayers: maxPlayers)
            session = newSession
            
            // Add host as player
            let host = try await cloudKit.addPlayer(
                sessionID: newSession.id,
                deviceID: deviceManager.deviceID,
                username: generateUsername(),
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
            try await cloudKit.updateSessionStatus(sessionID: session.id, status: "playing")
            
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
            try await cloudKit.updateSessionStatus(sessionID: session.id, status: "ended")
            gameState = .ended
            stopPlayerPolling()
        } catch {
            errorMessage = "Failed to end game: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Player Functions
    
    func joinSession(withCode code: String, username: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let foundSession = try await cloudKit.fetchSession(byJoinCode: code.uppercased()) else {
                errorMessage = "Session not found"
                isLoading = false
                return
            }
            
            guard foundSession.status == "waiting" else {
                errorMessage = "Game already started"
                isLoading = false
                return
            }
            
            // Check if session is full
            let existingPlayers = try await cloudKit.fetchPlayers(forSession: foundSession.id)
            guard existingPlayers.count < foundSession.maxPlayers else {
                errorMessage = "Session is full"
                isLoading = false
                return
            }
            
            // Join as player
            let player = try await cloudKit.addPlayer(
                sessionID: foundSession.id,
                deviceID: deviceManager.deviceID,
                username: username
            )
            
            session = foundSession
            players = existingPlayers + [player]
            gameState = .lobby
            
            // Start polling for updates
            startPlayerPolling()
            
        } catch {
            errorMessage = "Failed to join: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func leaveSession() {
        session = nil
        players = []
        gameState = .lobby
        stopPlayerPolling()
    }
    
    // MARK: - Game Logic
    
    private func loadQuestions() async {
        guard let session = session else { return }
        
        do {
            // Fetch free questions for now
            let allQuestions = try await cloudKit.fetchFreeQuestions()
            
            // Randomly select questions
            let selectedQuestions = allQuestions.shuffled().prefix(10)
            
            // Create session questions
            for (index, question) in selectedQuestions.enumerated() {
                let sessionQuestion = SessionQuestionModel(
                    sessionID: session.id,
                    questionID: question.id,
                    roundNumber: index + 1
                )
                
                let saved = try await cloudKit.save(sessionQuestion)
                sessionQuestions.append(saved)
            }
            
            // Load first question
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
              let currentSessionQuestion = sessionQuestions.first(where: { $0.roundNumber == session.roundCount + 1 }),
              let currentPlayer = players.first(where: { $0.deviceID == deviceManager.deviceID }) else {
            return
        }
        
        do {
            let vote = try await cloudKit.submitVote(
                sessionQuestionID: currentSessionQuestion.id,
                voterID: currentPlayer.id,
                votedForID: playerID
            )
            
            votes.append(vote)
            
        } catch {
            errorMessage = "Failed to submit vote: \(error.localizedDescription)"
        }
    }
    
    func loadVotes(for sessionQuestionID: UUID) async {
        do {
            votes = try await cloudKit.fetchVotes(forSessionQuestion: sessionQuestionID)
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
            players = try await cloudKit.fetchPlayers(forSession: session.id)
        } catch {
            print("Failed to refresh players: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helpers
    
    private func generateUsername() -> String {
        let adjectives = ["Cool", "Swift", "Happy", "Brave", "Smart", "Clever", "Wise", "Bold"]
        let nouns = ["Gamer", "Player", "Champion", "Winner", "Hero", "Star", "Master", "Pro"]
        
        return "\(adjectives.randomElement()!) \(nouns.randomElement()!)"
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
