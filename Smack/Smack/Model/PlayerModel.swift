//
//  PlayerModel.swift
//  Smack
//
import SwiftUI
import Foundation
import CloudKit

struct PlayerModel: Identifiable, Codable {
    var id: UUID
    var sessionID: UUID
    var deviceID: UUID
    var generatedUsername: String
    var role: String
    var isHost: Bool
    var points: Int
    var joinedAt: Date

    // ── character customization ──
    var colorIndex: Int
    var eyesIndex: Int
    var mouthIndex: Int
    var headwearIndex: Int

    var recordID: CKRecord.ID?

    enum CodingKeys: String, CodingKey {
        case id, sessionID, deviceID, generatedUsername, role, isHost, points, joinedAt
        case colorIndex, eyesIndex, mouthIndex, headwearIndex
    }

    init(
        id: UUID = UUID(),
        sessionID: UUID,
        deviceID: UUID,
        generatedUsername: String,
        role: String = "player",
        isHost: Bool = false,
        points: Int = 0,
        joinedAt: Date = Date(),
        colorIndex: Int = 0,
        eyesIndex: Int = 0,
        mouthIndex: Int = 0,
        headwearIndex: Int = 0
    ) {
        self.id = id
        self.sessionID = sessionID
        self.deviceID = deviceID
        self.generatedUsername = generatedUsername
        self.role = role
        self.isHost = isHost
        self.points = points
        self.joinedAt = joinedAt
        self.colorIndex = colorIndex
        self.eyesIndex = eyesIndex
        self.mouthIndex = mouthIndex
        self.headwearIndex = headwearIndex
    }

    init?(from record: CKRecord) {
        guard let id = record["id"] as? String,
              let sessionID = record["session_id"] as? String,
              let deviceID = record["device_id"] as? String,
              let username = record["generated_username"] as? String,
              let role = record["role"] as? String,
              let isHost = record["is_host"] as? Int,
              let points = record["points"] as? Int,
              let joinedAt = record["joined_at"] as? Date else {
            return nil
        }

        self.id = UUID(uuidString: id) ?? UUID()
        self.sessionID = UUID(uuidString: sessionID) ?? UUID()
        self.deviceID = UUID(uuidString: deviceID) ?? UUID()
        self.generatedUsername = username
        self.role = role
        self.isHost = isHost == 1
        self.points = points
        self.joinedAt = joinedAt
        self.colorIndex = record["color_index"] as? Int ?? 0
        self.eyesIndex = record["eyes_index"] as? Int ?? 0
        self.mouthIndex = record["mouth_index"] as? Int ?? 0
        self.headwearIndex = record["headwear_index"] as? Int ?? 0
        self.recordID = record.recordID
    }

    func toCKRecord() -> CKRecord {
        let record = recordID.map { CKRecord(recordType: "Player", recordID: $0) }
                     ?? CKRecord(recordType: "Player")

        record["id"] = id.uuidString as CKRecordValue
        record["session_id"] = sessionID.uuidString as CKRecordValue
        record["device_id"] = deviceID.uuidString as CKRecordValue
        record["generated_username"] = generatedUsername as CKRecordValue
        record["role"] = role as CKRecordValue
        record["is_host"] = (isHost ? 1 : 0) as CKRecordValue
        record["points"] = points as CKRecordValue
        record["joined_at"] = joinedAt as CKRecordValue
        record["color_index"] = colorIndex as CKRecordValue
        record["eyes_index"] = eyesIndex as CKRecordValue
        record["mouth_index"] = mouthIndex as CKRecordValue
        record["headwear_index"] = headwearIndex as CKRecordValue

        return record
    }
}

// ── helper to render character from indices ──
struct CharacterView: View {
    let player: PlayerModel
    let size: CGFloat

    var body: some View {
        ZStack {
            Image("CharacterBase_\(player.colorIndex)")
                .resizable().scaledToFit().frame(width: size)
            Image("Eyes_\(player.eyesIndex)")
                .resizable().scaledToFit().frame(width: size)
            Image("Mouth_\(player.mouthIndex)")
                .resizable().scaledToFit().frame(width: size)
            Image("Headwear_\(player.headwearIndex)")
                .resizable().scaledToFit().frame(width: size)
        }
    }
}
