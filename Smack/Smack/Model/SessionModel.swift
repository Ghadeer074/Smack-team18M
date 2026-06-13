//
//  sessionModel.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 24/11/1447 AH.
//


import Foundation
import CloudKit

struct sessionModel: Identifiable, Codable {
    var id: UUID
    var joinCode: String
    var status: String // "waiting", "playing", "ended"
    var maxPlayers: Int
    var maxAnswerers: Int? // Key type in ERD
    var roundCount: Int
    var startedAt: Date
    var endedAt: Date?
    
    // CloudKit Record (excluded from Codable)
    var recordID: CKRecord.ID?
    
    // Exclude recordID from Codable conformance
    enum CodingKeys: String, CodingKey {
        case id
        case joinCode
        case status
        case maxPlayers
        case maxAnswerers
        case roundCount
        case startedAt
        case endedAt
    }
    
    init(
        id: UUID = UUID(),
        joinCode: String,
        status: String = "waiting",
        maxPlayers: Int = 8,
        maxAnswerers: Int? = nil,
        roundCount: Int = 0,
        startedAt: Date = Date(),
        endedAt: Date? = nil
    ) {
        self.id = id
        self.joinCode = joinCode
        self.status = status
        self.maxPlayers = maxPlayers
        self.maxAnswerers = maxAnswerers
        self.roundCount = roundCount
        self.startedAt = startedAt
        self.endedAt = endedAt
    }
    
    // Convert from CKRecord
    init?(from record: CKRecord) {
        guard let id = record["id"] as? String,
              let joinCode = record["join_code"] as? String,
              let status = record["status"] as? String,
              let maxPlayers = record["max_players"] as? Int,
              let roundCount = record["round_count"] as? Int,
              let startedAt = record["started_at"] as? Date else {
            return nil
        }
        
        self.id = UUID(uuidString: id) ?? UUID()
        self.joinCode = joinCode
        self.status = status
        self.maxPlayers = maxPlayers
        self.maxAnswerers = record["max_answerers"] as? Int
        self.roundCount = roundCount
        self.startedAt = startedAt
        self.endedAt = record["ended_at"] as? Date
        self.recordID = record.recordID
    }
    
    // Convert to CKRecord
    func toCKRecord() -> CKRecord {
        let record = recordID.map { CKRecord(recordType: "session", recordID: $0) } 
                     ?? CKRecord(recordType: "session")
        
        record["id"] = id.uuidString as CKRecordValue
        record["join_code"] = joinCode as CKRecordValue
        record["status"] = status as CKRecordValue
        record["max_players"] = maxPlayers as CKRecordValue
        if let maxAnswerers = maxAnswerers {
            record["max_answerers"] = maxAnswerers as CKRecordValue
        }
        record["round_count"] = roundCount as CKRecordValue
        record["started_at"] = startedAt as CKRecordValue
        if let endedAt = endedAt {
            record["ended_at"] = endedAt as CKRecordValue
        }
        
        return record
    }
}
