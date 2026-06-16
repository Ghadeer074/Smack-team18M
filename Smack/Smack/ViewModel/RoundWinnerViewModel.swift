//
//  RoundWinnerViewModel.swift
//  Smack
//

import Foundation
import CloudKit

@MainActor
@Observable
class RoundWinnerViewModel {

    var winnerName: String = ""
    var winnerAnswer: String = ""
    var winnerPlayer: PlayerModel? = nil
    var isLoading = false
    var isLastRound = false
    var isDraw = false

    func loadRoundWinner(
        sessionQuestion: sessionQuestionModel,
        session: sessionModel
    ) async {
        isLoading = true
        do {
            let allSessions: [sessionModel] = try await CloudKitManager.shared.fetch(
                recordType: "session",
                predicate: NSPredicate(format: "join_code == %@", session.joinCode)
            )
            let totalRounds = allSessions.first?.roundCount ?? 1
            isLastRound = sessionQuestion.roundNumber >= totalRounds

            let votes = try await CloudKitManager.shared.fetchVotes(forsessionQuestion: sessionQuestion.id)
            let answers = try await CloudKitManager.shared.fetchAnswers(forSessionQuestion: sessionQuestion.id)
            let players = try await CloudKitManager.shared.fetchPlayers(forsession: session.id)

            let voteCounts = Dictionary(grouping: votes, by: { $0.answerID }).mapValues { $0.count }

            // ── check for draw ──
            let topVoteCount = voteCounts.values.max() ?? 0
            let topAnswers = voteCounts.filter { $0.value == topVoteCount }

            if topAnswers.count > 1 && topVoteCount > 0 {
                isDraw = true
            } else if let topAnswerID = topAnswers.keys.first,
                      let winningAnswer = answers.first(where: { $0.id == topAnswerID }) {
                winnerAnswer = winningAnswer.content
                if let winner = players.first(where: { $0.id == winningAnswer.playerID }) {
                    winnerName = winner.generatedUsername
                    winnerPlayer = winner
                    // ── update points ──
                    if let recordID = winner.recordID {
                        let record = try await CKContainer(identifier: "iCloud.com.Smack")
                            .publicCloudDatabase.record(for: recordID)
                        let current = record["points"] as? Int ?? 0
                        record["points"] = (current + 1) as CKRecordValue
                        try await CKContainer(identifier: "iCloud.com.Smack")
                            .publicCloudDatabase.save(record)
                    }
                }
            } else if let firstAnswer = answers.first {
                winnerAnswer = firstAnswer.content
                winnerPlayer = players.first(where: { $0.id == firstAnswer.playerID })
                winnerName = winnerPlayer?.generatedUsername ?? ""
            }

        } catch {
            print("❌ RoundWinner: \(error)")
        }
        isLoading = false
    }
}
