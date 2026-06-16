//
//  CharacterCustomizationViewModel.swift
//  Smack
//

import Foundation
import CloudKit

@MainActor
@Observable
class CharacterCustomizationViewModel {

    var isLoading = false
    var errorMessage: String?
    var playerCreated = false
    var createdPlayer: PlayerModel?

    func joinAsPlayer(
        name: String,
        session: sessionModel,
        role: String,
        isHost: Bool
    ) async {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "أدخل اسمك أولاً"
            return
        }

        isLoading = true
        errorMessage = nil
        // ── reset so onChange fires again ──
        playerCreated = false

        do {
            let deviceID = DeviceManager.shared.deviceID
            let finalRole = isHost ? "player" : role
            let container = CKContainer(identifier: "iCloud.com.Smack")
            let db = container.publicCloudDatabase

            let existing = try await CloudKitManager.shared.fetchPlayers(forsession: session.id)

            if let existingPlayer = existing.first(where: { $0.deviceID == deviceID }),
               let recordID = existingPlayer.recordID {
                // ── update name AND role ──
                let record = try await db.record(for: recordID)
                record["generated_username"] = name as CKRecordValue
                record["role"] = finalRole as CKRecordValue
                record["is_host"] = (isHost ? 1 : 0) as CKRecordValue
                let saved = try await db.save(record)
                createdPlayer = PlayerModel(from: saved)
            } else {
                // ── create new ──
                let record = CKRecord(recordType: "Player")
                record["id"] = UUID().uuidString as CKRecordValue
                record["session_id"] = session.id.uuidString as CKRecordValue
                record["device_id"] = deviceID.uuidString as CKRecordValue
                record["generated_username"] = name as CKRecordValue
                record["role"] = finalRole as CKRecordValue
                record["is_host"] = (isHost ? 1 : 0) as CKRecordValue
                record["points"] = 0 as CKRecordValue
                record["joined_at"] = Date() as CKRecordValue
                let saved = try await db.save(record)
                createdPlayer = PlayerModel(from: saved)
            }

            playerCreated = true

        } catch {
            errorMessage = "تعذر الانضمام، حاول مرة ثانية"
        }

        isLoading = false
    }
}
