//
//  GameSettingsViewModel.swift
//  Smack
//

import Foundation
import CloudKit

@MainActor
@Observable
class GameSettingsViewModel {

    var isLoading = false
    var errorMessage: String?
    var createdSession: sessionModel?
    var savedRoundCount: Int = 1  // ── exposed so Screen can read it ──

    func createSession(maxPlayers: Int, roundCount: Int) async {
        guard maxPlayers >= 2 else { errorMessage = "اختر عدد لاعبين (2 على الأقل)"; return }
        guard roundCount >= 1 else { errorMessage = "اختر عدد جولات (1 على الأقل)"; return }

        isLoading = true
        errorMessage = nil
        savedRoundCount = roundCount

        // Save to multiple places so nothing gets lost
        UserDefaults.standard.set(roundCount, forKey: "smack.totalRounds")
        UserDefaults.standard.synchronize()

        do {
            let code = String(format: "%04d", Int.random(in: 1000...9999))
            let container = CKContainer(identifier: "iCloud.com.Smack")
            let record = CKRecord(recordType: "session")
            record["id"] = UUID().uuidString as CKRecordValue
            record["join_code"] = code as CKRecordValue
            record["status"] = "waiting" as CKRecordValue
            record["max_players"] = maxPlayers as CKRecordValue
            record["round_count"] = roundCount as CKRecordValue
            record["started_at"] = Date() as CKRecordValue

            let saved = try await container.publicCloudDatabase.save(record)

            if var session = sessionModel(from: saved) {
                session.roundCount = roundCount  // force it regardless of what was read
                createdSession = session
            }

        } catch {
            errorMessage = "تعذر إنشاء الغرفة: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
