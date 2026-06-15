//
//  SubscriptionModel.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 24/11/1447 AH.
//

import Foundation
import CloudKit

struct SubscriptionModel: Identifiable, Codable {
    var id: UUID
    var deviceID: UUID
    var storeTransactionID: String
    var startedAt: Date
    var expiresAt: Date
    
    // CloudKit Record (excluded from Codable)
    var recordID: CKRecord.ID?
    
    // Define which properties should be encoded/decoded
    enum CodingKeys: String, CodingKey {
        case id
        case deviceID
        case storeTransactionID
        case startedAt
        case expiresAt
        // recordID is intentionally excluded since CKRecord.ID is not Codable
    }
    
    init(
        id: UUID = UUID(),
        deviceID: UUID,
        storeTransactionID: String,
        startedAt: Date = Date(),
        expiresAt: Date
    ) {
        self.id = id
        self.deviceID = deviceID
        self.storeTransactionID = storeTransactionID
        self.startedAt = startedAt
        self.expiresAt = expiresAt
    }
    
    // Convert from CKRecord
    init?(from record: CKRecord) {
        guard let id = record["id"] as? String,
              let deviceID = record["device_id"] as? String,
              let storeTransactionID = record["store_transaction_id"] as? String,
              let startedAt = record["started_at"] as? Date,
              let expiresAt = record["expires_at"] as? Date else {
            return nil
        }
        
        self.id = UUID(uuidString: id) ?? UUID()
        self.deviceID = UUID(uuidString: deviceID) ?? UUID()
        self.storeTransactionID = storeTransactionID
        self.startedAt = startedAt
        self.expiresAt = expiresAt
        self.recordID = record.recordID
    }
    
    // Convert to CKRecord
    func toCKRecord() -> CKRecord {
        let record = recordID.map { CKRecord(recordType: "Subscription", recordID: $0) } 
                     ?? CKRecord(recordType: "Subscription")
        
        record["id"] = id.uuidString as CKRecordValue
        record["device_id"] = deviceID.uuidString as CKRecordValue
        record["store_transaction_id"] = storeTransactionID as CKRecordValue
        record["started_at"] = startedAt as CKRecordValue
        record["expires_at"] = expiresAt as CKRecordValue
        
        return record
    }
}
