//
//  QuestionModel.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 24/11/1447 AH.
//

import Foundation
import CloudKit

struct QuestionModel: Identifiable, Codable {
    var id: UUID
    var categoryID: UUID
    var prompt: String
    var answer: String
    var isFree: Bool
    
    var recordID: CKRecord.ID?
    
    enum CodingKeys: String, CodingKey {
        case id
        case categoryID
        case prompt
        case answer
        case isFree
    }
    
    init(
        id: UUID = UUID(),
        categoryID: UUID,
        prompt: String,
        answer: String = "",
        isFree: Bool = true
    ) {
        self.id = id
        self.categoryID = categoryID
        self.prompt = prompt
        self.answer = answer
        self.isFree = isFree
    }
    
    init?(from record: CKRecord) {
        guard let id = record["id"] as? String,
              let categoryID = record["category_id"] as? String,
              let prompt = record["prompt"] as? String,
              let isFree = record["is_free"] as? Int else {
            return nil
        }
        
        self.id = UUID(uuidString: id) ?? UUID()
        self.categoryID = UUID(uuidString: categoryID) ?? UUID()
        self.prompt = prompt
        self.answer = record["answer"] as? String ?? ""
        self.isFree = isFree == 1
        self.recordID = record.recordID
    }
    
    func toCKRecord() -> CKRecord {
        let record = recordID.map { CKRecord(recordType: "Question", recordID: $0) }
                     ?? CKRecord(recordType: "Question")
        
        record["id"] = id.uuidString as CKRecordValue
        record["category_id"] = categoryID.uuidString as CKRecordValue
        record["prompt"] = prompt as CKRecordValue
        record["answer"] = answer as CKRecordValue
        record["is_free"] = (isFree ? 1 : 0) as CKRecordValue
        
        return record
    }
}
