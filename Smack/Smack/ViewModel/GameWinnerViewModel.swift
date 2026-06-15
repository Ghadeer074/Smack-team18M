//
//  GameWinnerViewModel.swift
//  Smack
//

import Foundation

@MainActor
@Observable
class GameWinnerViewModel {

    var winnerName: String = ""
    var isLoading = false

    func loadGameWinner(session: sessionModel) async {
        isLoading = true
        do {
            // ── جيب كل اللاعبين ──
            let players = try await CloudKitManager.shared.fetchPlayers(forsession: session.id)

            // ── جيب كل الـ SessionQuestions للـ session ──
            let predicate = NSPredicate(format: "session_id == %@", session.id.uuidString)
            let sessionQuestions: [sessionQuestionModel] = try await CloudKitManager.shared.fetch(
                recordType: "SessionQuestion", predicate: predicate
            )

            // ── لكل سؤال، جيب الأصوات وحسب نقاط كل لاعب ──
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

            // ── اللاعب بأكثر أصوات ──
            if let topPlayerID = playerVotes.max(by: { $0.value < $1.value })?.key,
               let winner = players.first(where: { $0.id == topPlayerID }) {
                winnerName = winner.generatedUsername
            } else {
                // ── لو ما في أصوات، خذ اللاعب بأكثر نقاط ──
                winnerName = players.max(by: { $0.points < $1.points })?.generatedUsername ?? "الكل شاطح!"
            }

            // ── غيّر status الـ session لـ ended ──
            try await CloudKitManager.shared.updatesessionStatus(
                sessionID: session.id,
                status: "ended"
            )
        } catch {
            print("❌ GameWinner error: \(error)")
            winnerName = "الكل شاطح!"
        }
        isLoading = false
    }
}
