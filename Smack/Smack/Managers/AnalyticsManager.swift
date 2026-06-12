//
//  AnalyticsManager.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 25/11/1447 AH.
//

import Foundation
import CloudKit
internal import Combine

// Analytics and telemetry for monitoring app usage and performance
@MainActor
class AnalyticsManager: ObservableObject {
    static let shared = AnalyticsManager()
    
    @Published var sessionMetrics = SessionMetrics()
    
    private let defaults = UserDefaults.standard
    
    // Keys
    private enum AnalyticsKey: String {
        case totalGamesPlayed
        case totalGamesHosted
        case totalVotesCast
        case totalPointsEarned
        case averageGameDuration
        case lastPlayedDate
        case lifetimeStats
    }
    
    struct SessionMetrics: Codable {
        var gamesPlayed: Int = 0
        var gamesHosted: Int = 0
        var votesCast: Int = 0
        var pointsEarned: Int = 0
        var sessionsJoined: Int = 0
        var averageRoundTime: TimeInterval = 0
    }
    
    struct GameSessionAnalytics: Codable {
        let sessionID: UUID
        let startTime: Date
        var endTime: Date?
        let playerCount: Int
        let isHost: Bool
        var roundsPlayed: Int = 0
        var votesSubmitted: Int = 0
        var pointsEarned: Int = 0
    }
    
    private init() {
        loadMetrics()
    }
    
    // MARK: - Event Tracking
    
    func trackGameCreated(sessionID: UUID, playerCount: Int) {
        sessionMetrics.gamesHosted += 1
        sessionMetrics.gamesPlayed += 1
        saveMetrics()
        
        logEvent("game_created", parameters: [
            "session_id": sessionID.uuidString,
            "player_count": playerCount
        ])
    }
    
    func trackGameJoined(sessionID: UUID, joinCode: String) {
        sessionMetrics.gamesPlayed += 1
        sessionMetrics.sessionsJoined += 1
        saveMetrics()
        
        logEvent("game_joined", parameters: [
            "session_id": sessionID.uuidString,
            "join_code": joinCode
        ])
    }
    
    func trackVoteSubmitted(questionID: UUID, votedForPlayerID: UUID) {
        sessionMetrics.votesCast += 1
        saveMetrics()
        
        logEvent("vote_submitted", parameters: [
            "question_id": questionID.uuidString,
            "voted_for": votedForPlayerID.uuidString
        ])
    }
    
    func trackPointsEarned(amount: Int, reason: String) {
        sessionMetrics.pointsEarned += amount
        saveMetrics()
        
        logEvent("points_earned", parameters: [
            "amount": amount,
            "reason": reason
        ])
    }
    
    func trackGameEnded(sessionID: UUID, duration: TimeInterval, finalScore: Int) {
        updateAverageGameDuration(duration)
        
        logEvent("game_ended", parameters: [
            "session_id": sessionID.uuidString,
            "duration_seconds": Int(duration),
            "final_score": finalScore
        ])
    }
    
    func trackError(_ error: Error, context: String) {
        logEvent("error_occurred", parameters: [
            "error": error.localizedDescription,
            "context": context
        ])
    }
    
    func trackPurchase(itemID: String, price: String) {
        logEvent("purchase_made", parameters: [
            "item_id": itemID,
            "price": price
        ])
    }
    
    func trackSubscription(type: String, duration: String) {
        logEvent("subscription_started", parameters: [
            "type": type,
            "duration": duration
        ])
    }
    
    // MARK: - Metrics Persistence
    
    private func loadMetrics() {
        if let data = defaults.data(forKey: AnalyticsKey.lifetimeStats.rawValue),
           let metrics = try? JSONDecoder().decode(SessionMetrics.self, from: data) {
            sessionMetrics = metrics
        }
    }
    
    private func saveMetrics() {
        if let encoded = try? JSONEncoder().encode(sessionMetrics) {
            defaults.set(encoded, forKey: AnalyticsKey.lifetimeStats.rawValue)
        }
        
        defaults.set(Date(), forKey: AnalyticsKey.lastPlayedDate.rawValue)
    }
    
    private func updateAverageGameDuration(_ duration: TimeInterval) {
        let totalGames = Double(sessionMetrics.gamesPlayed)
        let currentAvg = sessionMetrics.averageRoundTime
        
        // Calculate new average
        let newAvg = ((currentAvg * (totalGames - 1)) + duration) / totalGames
        sessionMetrics.averageRoundTime = newAvg
        
        saveMetrics()
    }
    
    // MARK: - Stats Retrieval
    
    var lifetimeStats: [String: Any] {
        [
            "games_played": sessionMetrics.gamesPlayed,
            "games_hosted": sessionMetrics.gamesHosted,
            "votes_cast": sessionMetrics.votesCast,
            "points_earned": sessionMetrics.pointsEarned,
            "average_game_duration": sessionMetrics.averageRoundTime
        ]
    }
    
    var lastPlayedDate: Date? {
        defaults.object(forKey: AnalyticsKey.lastPlayedDate.rawValue) as? Date
    }
    
    // MARK: - CloudKit Analytics (Optional)
    
    // Store aggregated analytics in CloudKit for insights
    func syncAnalyticsToCloud() async {
        guard sessionMetrics.gamesPlayed > 0 else { return }
        
        let analyticsRecord = CKRecord(recordType: "Analytics")
        analyticsRecord["device_id"] = DeviceManager.shared.deviceID.uuidString as CKRecordValue
        analyticsRecord["games_played"] = sessionMetrics.gamesPlayed as CKRecordValue
        analyticsRecord["games_hosted"] = sessionMetrics.gamesHosted as CKRecordValue
        analyticsRecord["votes_cast"] = sessionMetrics.votesCast as CKRecordValue
        analyticsRecord["points_earned"] = sessionMetrics.pointsEarned as CKRecordValue
        analyticsRecord["synced_at"] = Date() as CKRecordValue
        
        do {
            let container = CKContainer(identifier: "iCloud.com.Smack")
            _ = try await container.publicCloudDatabase.save(analyticsRecord)
            print("✅ Analytics synced to CloudKit")
        } catch {
            print("❌ Failed to sync analytics: \(error)")
        }
    }
    
    // MARK: - Performance Monitoring
    
    struct PerformanceMetric {
        let name: String
        let startTime: Date
        var endTime: Date?
        
        var duration: TimeInterval? {
            guard let endTime = endTime else { return nil }
            return endTime.timeIntervalSince(startTime)
        }
    }
    
    private var activeMetrics: [String: PerformanceMetric] = [:]
    
    func startPerformanceTracking(_ operation: String) {
        let metric = PerformanceMetric(name: operation, startTime: Date())
        activeMetrics[operation] = metric
    }
    
    func endPerformanceTracking(_ operation: String) {
        guard var metric = activeMetrics[operation] else { return }
        
        metric.endTime = Date()
        activeMetrics.removeValue(forKey: operation)
        
        if let duration = metric.duration {
            logEvent("performance", parameters: [
                "operation": operation,
                "duration_ms": Int(duration * 1000)
            ])
            
            // Alert if operation is slow
            if duration > 3.0 {
                print("⚠️ Slow operation detected: \(operation) took \(duration)s")
            }
        }
    }
    
    // MARK: - Logging
    
    private func logEvent(_ event: String, parameters: [String: Any] = [:]) {
        var logMessage = "📊 Analytics: \(event)"
        
        if !parameters.isEmpty {
            let paramsString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
            logMessage += " | \(paramsString)"
        }
        
        print(logMessage)
        
        // Here you would integrate with your analytics service
        // Examples: Firebase, Mixpanel, Amplitude, etc.
    }
    
    // MARK: - Reset
    
    func resetAnalytics() {
        sessionMetrics = SessionMetrics()
        saveMetrics()
        print("🔄 Analytics reset")
    }
}

//// MARK: - Analytics View Extension
//
//import SwiftUI
//
//extension View {
//    // Track screen views automatically
//    func trackScreenView(_ screenName: String) -> some View {
//        self.onAppear {
//            AnalyticsManager.shared.logEvent("screen_view", parameters: [
//                "screen_name": screenName
//            ])
//        }
//    }
//    
//    /// Track timed operations
//    func trackPerformance(_ operation: String) -> some View {
//        self
//            .onAppear {
//                AnalyticsManager.shared.startPerformanceTracking(operation)
//            }
//            .onDisappear {
//                AnalyticsManager.shared.endPerformanceTracking(operation)
//            }
//    }
//}

// MARK: - Analytics Dashboard View
//
//struct AnalyticsDashboardView: View {
//    @ObservedObject var analytics = AnalyticsManager.shared
//    
//    var body: some View {
//        NavigationStack {
//            List {
//                Section("Lifetime Stats") {
//                    StatRow(label: "Games Played", value: "\(analytics.sessionMetrics.gamesPlayed)")
//                    StatRow(label: "Games Hosted", value: "\(analytics.sessionMetrics.gamesHosted)")
//                    StatRow(label: "Votes Cast", value: "\(analytics.sessionMetrics.votesCast)")
//                    StatRow(label: "Total Points", value: "\(analytics.sessionMetrics.pointsEarned)")
//                }
//                
//                Section("Averages") {
//                    StatRow(
//                        label: "Avg Game Duration",
//                        value: formatDuration(analytics.sessionMetrics.averageRoundTime)
//                    )
//                }
//                
//                Section("Activity") {
//                    if let lastPlayed = analytics.lastPlayedDate {
//                        StatRow(label: "Last Played", value: formatDate(lastPlayed))
//                    } else {
//                        Text("No games played yet")
//                            .foregroundColor(.secondary)
//                    }
//                }
//                
//                Section {
//                    Button("Sync Analytics") {
//                        Task {
//                            await analytics.syncAnalyticsToCloud()
//                        }
//                    }
//                    
//                    Button("Reset Stats", role: .destructive) {
//                        analytics.resetAnalytics()
//                    }
//                }
//            }
//            .navigationTitle("Statistics")
//        }
//    }
//    
//    private func formatDuration(_ seconds: TimeInterval) -> String {
//        guard seconds > 0 else { return "N/A" }
//        
//        let minutes = Int(seconds) / 60
//        let remainingSeconds = Int(seconds) % 60
//        
//        if minutes > 0 {
//            return "\(minutes)m \(remainingSeconds)s"
//        } else {
//            return "\(remainingSeconds)s"
//        }
//    }
//    
//    private func formatDate(_ date: Date) -> String {
//        let formatter = RelativeDateTimeFormatter()
//        formatter.unitsStyle = .full
//        return formatter.localizedString(for: date, relativeTo: Date())
//    }
//}
//
//struct StatRow: View {
//    let label: String
//    let value: String
//    
//    var body: some View {
//        HStack {
//            Text(label)
//            Spacer()
//            Text(value)
//                .foregroundColor(.secondary)
//                .fontWeight(.medium)
//        }
//    }
//}
//
//// MARK: - Usage Examples
//
///*
// 
// في GameSessionViewModel:
// 
// func createSession(maxPlayers: Int = 8) async {
//     AnalyticsManager.shared.startPerformanceTracking("create_session")
//     
//     // ... create session logic ...
//     
//     if let session = session {
//         AnalyticsManager.shared.trackGameCreated(
//             sessionID: session.id,
//             playerCount: maxPlayers
//         )
//     }
//     
//     AnalyticsManager.shared.endPerformanceTracking("create_session")
// }
// 
// func submitVote(for playerID: UUID) async {
//     // ... submit vote logic ...
//     
//     AnalyticsManager.shared.trackVoteSubmitted(
//         questionID: currentQuestionID,
//         votedForPlayerID: playerID
//     )
// }
// 
// في Views:
// 
// struct GameView: View {
//     var body: some View {
//         VStack {
//             // ... content ...
//         }
//         .trackScreenView("game_screen")
//         .trackPerformance("game_view_load")
//     }
// }
// 
// */
//
//#Preview("Analytics Dashboard") {
//    AnalyticsDashboardView()
//}
