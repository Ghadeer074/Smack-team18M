//
//  SessionQuestionModel.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 24/11/1447 AH.
//

import Foundation
import CloudKit

struct SessionQuestionModel: Identifiable, Codable {
    var id: UUID
    var sessionID: UUID
    var questionID: UUID
    var roundNumber: Int
    var wasAnswered: Bool
    
    // CloudKit Record (not encoded/decoded)
    var recordID: CKRecord.ID?
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id
        case sessionID
        case questionID
        case roundNumber
        case wasAnswered
    }
    
    init(
        id: UUID = UUID(),
        sessionID: UUID,
        questionID: UUID,
        roundNumber: Int = 1,
        wasAnswered: Bool = false
    ) {
        self.id = id
        self.sessionID = sessionID
        self.questionID = questionID
        self.roundNumber = roundNumber
        self.wasAnswered = wasAnswered
    }
    
    // Convert from CKRecord
    init?(from record: CKRecord) {
        guard let id = record["id"] as? String,
              let sessionID = record["session_id"] as? String,
              let questionID = record["question_id"] as? String,
              let roundNumber = record["round_number"] as? Int,
              let wasAnswered = record["was_answerd"] as? Int else { // Note: typo in ERD "answerd"
            return nil
        }
        
        self.id = UUID(uuidString: id) ?? UUID()
        self.sessionID = UUID(uuidString: sessionID) ?? UUID()
        self.questionID = UUID(uuidString: questionID) ?? UUID()
        self.roundNumber = roundNumber
        self.wasAnswered = wasAnswered == 1
        self.recordID = record.recordID
    }
    
    // Convert to CKRecord
    func toCKRecord() -> CKRecord {
        let record = recordID.map { CKRecord(recordType: "SessionQuestion", recordID: $0) } 
                     ?? CKRecord(recordType: "SessionQuestion")
        
        record["id"] = id.uuidString as CKRecordValue
        record["session_id"] = sessionID.uuidString as CKRecordValue
        record["question_id"] = questionID.uuidString as CKRecordValue
        record["round_number"] = roundNumber as CKRecordValue
        record["was_answerd"] = (wasAnswered ? 1 : 0) as CKRecordValue
        
        return record
    }
}
