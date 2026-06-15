//
//  PlayerModel.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 24/11/1447 AH.
//
import Foundation
import CloudKit

struct PlayerModel: Identifiable, Codable {
    var id: UUID
    var sessionID: UUID
    var deviceID: UUID
    var generatedUsername: String
    var role: String // "host" or "player"
    var isHost: Bool
    var points: Int
    var joinedAt: Date
    
    // CloudKit Record (excluded from Codable)
    var recordID: CKRecord.ID?
    
    // Specify which properties to include in Codable
    enum CodingKeys: String, CodingKey {
        case id
        case sessionID
        case deviceID
        case generatedUsername
        case role
        case isHost
        case points
        case joinedAt
    }
    
    init(
        id: UUID = UUID(),
        sessionID: UUID,
        deviceID: UUID,
        generatedUsername: String,
        role: String = "player",
        isHost: Bool = false,
        points: Int = 0,
        joinedAt: Date = Date()
    ) {
        self.id = id
        self.sessionID = sessionID
        self.deviceID = deviceID
        self.generatedUsername = generatedUsername
        self.role = role
        self.isHost = isHost
        self.points = points
        self.joinedAt = joinedAt
    }
    
    // Convert from CKRecord
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
        self.recordID = record.recordID
    }
    
    // Convert to CKRecord
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
        
        return record
    }
}
