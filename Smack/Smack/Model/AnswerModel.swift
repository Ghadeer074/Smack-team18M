//
//  AnswerModel.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 28/12/1447 AH.
//
import Foundation
import CloudKit

struct AnswerModel: Identifiable, Codable {
    var id: UUID
    var sessionQuestionID: UUID
    var playerID: UUID
    var content: String
    var submittedAt: Date
    
    // CloudKit Record
    var recordID: CKRecord.ID?
    
    enum CodingKeys: String, CodingKey {
        case id
        case sessionQuestionID
        case playerID
        case content
        case submittedAt
    }
    
    init(
        id: UUID = UUID(),
        sessionQuestionID: UUID,
        playerID: UUID,
        content: String,
        submittedAt: Date = Date()
    ) {
        self.id = id
        self.sessionQuestionID = sessionQuestionID
        self.playerID = playerID
        self.content = content
        self.submittedAt = submittedAt
    }
    
    // Convert from CKRecord
    init?(from record: CKRecord) {
        guard let id = record["id"] as? String,
              let sessionQuestionID = record["session_question_id"] as? String,
              let playerID = record["player_id"] as? String,
              let content = record["content"] as? String,
              let submittedAt = record["submitted_at"] as? Date else {
            return nil
        }
        
        self.id = UUID(uuidString: id) ?? UUID()
        self.sessionQuestionID = UUID(uuidString: sessionQuestionID) ?? UUID()
        self.playerID = UUID(uuidString: playerID) ?? UUID()
        self.content = content
        self.submittedAt = submittedAt
        self.recordID = record.recordID
    }
    
    // Convert to CKRecord
    func toCKRecord() -> CKRecord {
        let record = recordID.map { CKRecord(recordType: "Answer", recordID: $0) }
                     ?? CKRecord(recordType: "Answer")
        
        record["id"] = id.uuidString as CKRecordValue
        record["session_question_id"] = sessionQuestionID.uuidString as CKRecordValue
        record["player_id"] = playerID.uuidString as CKRecordValue
        record["content"] = content as CKRecordValue
        record["submitted_at"] = submittedAt as CKRecordValue
        
        return record
    }
}
