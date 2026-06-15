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

        do {
            let deviceID = DeviceManager.shared.deviceID

            // ── تحقق إذا موجود أصلاً ──
            let existingPlayers = try await CloudKitManager.shared.fetchPlayers(forsession: session.id)
            if let existing = existingPlayers.first(where: { $0.deviceID == deviceID }) {
                createdPlayer = existing
                playerCreated = true
                isLoading = false
                return
            }

            // ── الهوست دائماً player، المصوت voter ──
            let finalRole = isHost ? "player" : role

            // ── نبني الـ record مباشرة بدون save مزدوج ──
            let container = CKContainer(identifier: "iCloud.com.Smack")
            let record = CKRecord(recordType: "Player")
            record["id"] = UUID().uuidString as CKRecordValue
            record["session_id"] = session.id.uuidString as CKRecordValue
            record["device_id"] = deviceID.uuidString as CKRecordValue
            record["generated_username"] = name as CKRecordValue
            record["role"] = finalRole as CKRecordValue
            record["is_host"] = (isHost ? 1 : 0) as CKRecordValue
            record["points"] = 0 as CKRecordValue
            record["joined_at"] = Date() as CKRecordValue

            let saved = try await container.publicCloudDatabase.save(record)

            if let player = PlayerModel(from: saved) {
                createdPlayer = player
                playerCreated = true
            }

        } catch {
            errorMessage = "تعذر الانضمام، حاول مرة ثانية"
            print("❌ join error: \(error)")
        }

        isLoading = false
    }
}
