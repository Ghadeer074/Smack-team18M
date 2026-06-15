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

    func createSession(maxPlayers: Int, roundCount: Int) async {
        guard maxPlayers >= 2 else { errorMessage = "اختر عدد لاعبين (2 على الأقل)"; return }
        guard roundCount >= 1 else { errorMessage = "اختر عدد جولات (1 على الأقل)"; return }

        isLoading = true
        errorMessage = nil

        do {
            let code = String(format: "%04d", Int.random(in: 1000...9999))

            // ── نبني الـ record مباشرة بكل الحقول دفعة وحدة ──
            let container = CKContainer(identifier: "iCloud.com.Smack")
            let record = CKRecord(recordType: "session")
            record["id"] = UUID().uuidString as CKRecordValue
            record["join_code"] = code as CKRecordValue
            record["status"] = "waiting" as CKRecordValue
            record["max_players"] = maxPlayers as CKRecordValue
            record["round_count"] = roundCount as CKRecordValue
            record["started_at"] = Date() as CKRecordValue

            let saved = try await container.publicCloudDatabase.save(record)

            if let session = sessionModel(from: saved) {
                createdSession = session
            }

        } catch {
            errorMessage = "تعذر إنشاء الغرفة: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
