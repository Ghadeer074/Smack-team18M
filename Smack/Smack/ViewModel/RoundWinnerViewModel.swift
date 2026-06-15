//
//  RoundWinnerViewModel.swift
//  Smack
//

import Foundation

@MainActor
@Observable
class RoundWinnerViewModel {

    var winnerName: String = ""
    var winnerAnswer: String = ""
    var isLoading = false
    var isLastRound = false

    func loadRoundWinner(
        sessionQuestion: sessionQuestionModel,
        session: sessionModel,
        totalRounds: Int
    ) async {
        isLoading = true
        do {
            // ── totalRounds من الـ SessionQuestion record مباشرة ──
            let rounds = sessionQuestion.totalRounds > 1 ? sessionQuestion.totalRounds : totalRounds
            print("✅ Round \(sessionQuestion.roundNumber) of \(rounds)")

            let votes = try await CloudKitManager.shared.fetchVotes(forsessionQuestion: sessionQuestion.id)
            let answers = try await CloudKitManager.shared.fetchAnswers(forSessionQuestion: sessionQuestion.id)

            let voteCounts = Dictionary(grouping: votes, by: { $0.answerID }).mapValues { $0.count }

            if let topAnswerID = voteCounts.max(by: { $0.value < $1.value })?.key,
               let winningAnswer = answers.first(where: { $0.id == topAnswerID }) {
                winnerAnswer = winningAnswer.content
                let players = try await CloudKitManager.shared.fetchPlayers(forsession: session.id)
                if let winner = players.first(where: { $0.id == winningAnswer.playerID }) {
                    winnerName = winner.generatedUsername
                    try await CloudKitManager.shared.updatePlayerPoints(
                        playerID: winner.id, points: winner.points + 1
                    )
                }
            } else if let firstAnswer = answers.first {
                winnerAnswer = firstAnswer.content
                let players = try await CloudKitManager.shared.fetchPlayers(forsession: session.id)
                winnerName = players.first(where: { $0.id == firstAnswer.playerID })?.generatedUsername ?? ""
            }

            isLastRound = sessionQuestion.roundNumber >= rounds

        } catch {
            print("❌ RoundWinner: \(error)")
        }
        isLoading = false
    }
}
