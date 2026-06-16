//
//  GameWinnerViewModel.swift
//  Smack
//

import Foundation
import CloudKit

@MainActor
@Observable
class GameWinnerViewModel {

    var winnerName: String = ""
    var winnerPlayer: PlayerModel? = nil
    var isDraw: Bool = false
    var isLoading = false

    func loadGameWinner(session: sessionModel) async {
        isLoading = true
        do {
            let players = try await CloudKitManager.shared.fetchPlayers(forsession: session.id)
            let predicate = NSPredicate(format: "session_id == %@", session.id.uuidString)
            let sessionQuestions: [sessionQuestionModel] = try await CloudKitManager.shared.fetch(
                recordType: "SessionQuestion", predicate: predicate
            )

            var playerVotes: [UUID: Int] = [:]
            for sq in sessionQuestions {
                let answers = try await CloudKitManager.shared.fetchAnswers(forSessionQuestion: sq.id)
                let votes = try await CloudKitManager.shared.fetchVotes(forsessionQuestion: sq.id)
                for vote in votes {
                    if let answer = answers.first(where: { $0.id == vote.answerID }) {
                        playerVotes[answer.playerID, default: 0] += 1
                    }
                }
            }

            let topVotes = playerVotes.values.max() ?? 0
            let topPlayers = players.filter { (playerVotes[$0.id] ?? 0) == topVotes && topVotes > 0 }

            if topPlayers.count > 1 {
                isDraw = true
                winnerName = topPlayers.map { $0.generatedUsername }.joined(separator: " & ")
            } else if let winner = topPlayers.first {
                winnerPlayer = winner
                winnerName = winner.generatedUsername
            } else {
                winnerPlayer = players.max(by: { $0.points < $1.points })
                winnerName = winnerPlayer?.generatedUsername ?? "الكل شاطح!"
            }

            try await CloudKitManager.shared.updatesessionStatus(
                sessionID: session.id,
                status: "ended"
            )
        } catch {
            print("❌ GameWinner: \(error)")
        }
        isLoading = false
    }
}
