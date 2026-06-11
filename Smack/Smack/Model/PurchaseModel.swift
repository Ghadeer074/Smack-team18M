//
//  PurchaseModel.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 24/11/1447 AH.
//

import Foundation
import CloudKit

struct PurchaseModel: Identifiable, Codable {
    var id: UUID
    var deviceID: UUID
    var unlockableItemID: UUID
    var storeTransactionID: String
    var purchasedAt: Date
    
    // CloudKit Record
    var recordID: CKRecord.ID?
    
    // Exclude recordID from Codable since CKRecord.ID is not Codable
    enum CodingKeys: String, CodingKey {
        case id
        case deviceID
        case unlockableItemID
        case storeTransactionID
        case purchasedAt
    }
    
    init(
        id: UUID = UUID(),
        deviceID: UUID,
        unlockableItemID: UUID,
        storeTransactionID: String,
        purchasedAt: Date = Date()
    ) {
        self.id = id
        self.deviceID = deviceID
        self.unlockableItemID = unlockableItemID
        self.storeTransactionID = storeTransactionID
        self.purchasedAt = purchasedAt
    }
    
    // Convert from CKRecord
    init?(from record: CKRecord) {
        guard let id = record["id"] as? String,
              let deviceID = record["Device_id"] as? String, // Note: Capital D in ERD
              let unlockableItemID = record["unlockable_item_id"] as? String,
              let storeTransactionID = record["store_transaction_id"] as? String,
              let purchasedAt = record["purchased_at"] as? Date else {
            return nil
        }
        
        self.id = UUID(uuidString: id) ?? UUID()
        self.deviceID = UUID(uuidString: deviceID) ?? UUID()
        self.unlockableItemID = UUID(uuidString: unlockableItemID) ?? UUID()
        self.storeTransactionID = storeTransactionID
        self.purchasedAt = purchasedAt
        self.recordID = record.recordID
    }
    
    // Convert to CKRecord
    func toCKRecord() -> CKRecord {
        let record = recordID.map { CKRecord(recordType: "Purchase", recordID: $0) } 
                     ?? CKRecord(recordType: "Purchase")
        
        record["id"] = id.uuidString as CKRecordValue
        record["Device_id"] = deviceID.uuidString as CKRecordValue
        record["unlockable_item_id"] = unlockableItemID.uuidString as CKRecordValue
        record["store_transaction_id"] = storeTransactionID as CKRecordValue
        record["purchased_at"] = purchasedAt as CKRecordValue
        
        return record
    }
}
