//
//   CategoryModel.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 25/11/1447 AH.
//


import Foundation
import CloudKit
internal import Combine 

struct CategoryModel: Identifiable, Codable {
    var id: UUID
    var name: String
    var isFree: Bool
    
    // CloudKit Record (not encoded/decoded)
    var recordID: CKRecord.ID?
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isFree
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        isFree: Bool = true
    ) {
        self.id = id
        self.name = name
        self.isFree = isFree
    }
    
    // Convert from CKRecord
    init?(from record: CKRecord) {
        guard let id = record["id"] as? String,
              let name = record["name"] as? String,
              let isFree = record["is_free"] as? Int else {
            return nil
        }
        
        self.id = UUID(uuidString: id) ?? UUID()
        self.name = name
        self.isFree = isFree == 1
        self.recordID = record.recordID
    }
    
    // Convert to CKRecord
    func toCKRecord() -> CKRecord {
        let record = recordID.map { CKRecord(recordType: "Category", recordID: $0) } 
                     ?? CKRecord(recordType: "Category")
        
        record["id"] = id.uuidString as CKRecordValue
        record["name"] = name as CKRecordValue
        record["is_free"] = (isFree ? 1 : 0) as CKRecordValue
        
        return record
    }
}
