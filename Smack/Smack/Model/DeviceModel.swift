//
//  DeviceModel.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 24/11/1447 AH.
//

import Foundation
import CloudKit


struct DeviceModel: Identifiable, Codable {
    var id: UUID
    var timestamp: Date // first_seen - First time the device ever launched the game
    
    // CloudKit Record
    var recordID: CKRecord.ID?
    
    // MARK: - Codable Support
    enum CodingKeys: String, CodingKey {
        case id
        case timestamp
    }
    
    init(id: UUID = UUID(), timestamp: Date = Date()) {
        self.id = id
        self.timestamp = timestamp
    }
    
    // Convert from CKRecord
    init?(from record: CKRecord) {
        guard let id = record["device_id"] as? String,
              let timestamp = record["first_seen"] as? Date else {
            return nil
        }
        
        self.id = UUID(uuidString: id) ?? UUID()
        self.timestamp = timestamp
        self.recordID = record.recordID
    }
    
    // Convert to CKRecord
    func toCKRecord() -> CKRecord {
        let record = recordID.map { CKRecord(recordType: "Device", recordID: $0) } 
                     ?? CKRecord(recordType: "Device")
        
        record["device_id"] = id.uuidString as CKRecordValue
        record["first_seen"] = timestamp as CKRecordValue
        
        return record
    }
}
