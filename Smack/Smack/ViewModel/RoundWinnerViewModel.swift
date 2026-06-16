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
    var isLoading = false
    var isLastRound = false

    func loadRoundWinner(
        sessionQuestion: sessionQuestionModel,
        session: sessionModel
    ) async {
        isLoading = true
        do {
            // ── fetch round_count directly from session record ──
            let allSessions: [sessionModel] = try await CloudKitManager.shared.fetch(
                recordType: "session",
                predicate: NSPredicate(format: "join_code == %@", session.joinCode)
            )
            let totalRounds = allSessions.first?.roundCount ?? 1

            isLastRound = sessionQuestion.roundNumber >= totalRounds

            let votes = try await CloudKitManager.shared.fetchVotes(forsessionQuestion: sessionQuestion.id)
            let answers = try await CloudKitManager.shared.fetchAnswers(forSessionQuestion: sessionQuestion.id)

            let voteCounts = Dictionary(grouping: votes, by: { $0.answerID }).mapValues { $0.count }

            if let topAnswerID = voteCounts.max(by: { $0.value < $1.value })?.key,
               let winningAnswer = answers.first(where: { $0.id == topAnswerID }) {
                winnerAnswer = winningAnswer.content
                let players = try await CloudKitManager.shared.fetchPlayers(forsession: session.id)
                if let winner = players.first(where: { $0.id == winningAnswer.playerID }),
                   let recordID = winner.recordID {
                    winnerName = winner.generatedUsername
                    // ── update points using recordID directly, no id query ──
                    let record = try await CKContainer(identifier: "iCloud.com.Smack")
                        .publicCloudDatabase.record(for: recordID)
                    let current = record["points"] as? Int ?? 0
                    record["points"] = (current + 1) as CKRecordValue
                    try await CKContainer(identifier: "iCloud.com.Smack")
                        .publicCloudDatabase.save(record)
                }
            } else if let firstAnswer = answers.first {
                winnerAnswer = firstAnswer.content
                let players = try await CloudKitManager.shared.fetchPlayers(forsession: session.id)
                winnerName = players.first(where: { $0.id == firstAnswer.playerID })?.generatedUsername ?? ""
            }

        } catch {
            print("❌ RoundWinner: \(error)")
        }
        isLoading = false
    }
}
