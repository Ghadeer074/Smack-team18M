//
//  VoteModel.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 24/11/1447 AH.
//

import Foundation
import CloudKit

struct VoteModel: Identifiable, Codable {
    var id: UUID
    var sessionQuestionID: UUID
    var voterParticipantID: UUID
    var votedForParticipantID: UUID
    var votedAt: Date
    
    // CloudKit Record
    var recordID: CKRecord.ID?
    
    // Exclude recordID from Codable since CKRecord.ID is not Codable
    enum CodingKeys: String, CodingKey {
        case id
        case sessionQuestionID
        case voterParticipantID
        case votedForParticipantID
        case votedAt
    }
    
    init(
        id: UUID = UUID(),
        sessionQuestionID: UUID,
        voterParticipantID: UUID,
        votedForParticipantID: UUID,
        votedAt: Date = Date()
    ) {
        self.id = id
        self.sessionQuestionID = sessionQuestionID
        self.voterParticipantID = voterParticipantID
        self.votedForParticipantID = votedForParticipantID
        self.votedAt = votedAt
    }
    
    // Convert from CKRecord
    init?(from record: CKRecord) {
        guard let id = record["id"] as? String,
              let sessionQuestionID = record["session_question_id"] as? String,
              let voterParticipantID = record["voter_participant_id"] as? String,
              let votedForParticipantID = record["voted_for_participant_id"] as? String,
              let votedAt = record["voted_at"] as? Date else {
            return nil
        }
        
        self.id = UUID(uuidString: id) ?? UUID()
        self.sessionQuestionID = UUID(uuidString: sessionQuestionID) ?? UUID()
        self.voterParticipantID = UUID(uuidString: voterParticipantID) ?? UUID()
        self.votedForParticipantID = UUID(uuidString: votedForParticipantID) ?? UUID()
        self.votedAt = votedAt
        self.recordID = record.recordID
    }
    
    // Convert to CKRecord
    func toCKRecord() -> CKRecord {
        let record = recordID.map { CKRecord(recordType: "Vote", recordID: $0) } 
                     ?? CKRecord(recordType: "Vote")
        
        record["id"] = id.uuidString as CKRecordValue
        record["session_question_id"] = sessionQuestionID.uuidString as CKRecordValue
        record["voter_participant_id"] = voterParticipantID.uuidString as CKRecordValue
        record["voted_for_participant_id"] = votedForParticipantID.uuidString as CKRecordValue
        record["voted_at"] = votedAt as CKRecordValue
        
        return record
    }
}
