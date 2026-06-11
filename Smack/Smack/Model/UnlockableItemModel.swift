//
//  UnlockableItemModel.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 24/11/1447 AH.
//

import Foundation
import CloudKit

struct UnlockableItemModel: Identifiable, Codable {
    var id: UUID
    var type: String // e.g., "category", "theme", "avatar"
    var refID: String // Reference to the specific item (category_id, theme_id, etc.)
    var itemID: String
    var label: String
    var isPremium: Bool
    
    // CloudKit Record (excluded from Codable)
    var recordID: CKRecord.ID?
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, type, refID, itemID, label, isPremium
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        refID = try container.decode(String.self, forKey: .refID)
        itemID = try container.decode(String.self, forKey: .itemID)
        label = try container.decode(String.self, forKey: .label)
        isPremium = try container.decode(Bool.self, forKey: .isPremium)
        recordID = nil // CloudKit record ID is not decoded
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(refID, forKey: .refID)
        try container.encode(itemID, forKey: .itemID)
        try container.encode(label, forKey: .label)
        try container.encode(isPremium, forKey: .isPremium)
        // recordID is intentionally not encoded
    }
    
    init(
        id: UUID = UUID(),
        type: String,
        refID: String,
        itemID: String,
        label: String,
        isPremium: Bool = false
    ) {
        self.id = id
        self.type = type
        self.refID = refID
        self.itemID = itemID
        self.label = label
        self.isPremium = isPremium
    }
    
    // Convert from CKRecord
    init?(from record: CKRecord) {
        guard let id = record["id"] as? String,
              let type = record["type"] as? String,
              let refID = record["ref_id"] as? String,
              let itemID = record["item_id"] as? String,
              let label = record["label"] as? String,
              let isPremium = record["is_premium"] as? Int else {
            return nil
        }
        
        self.id = UUID(uuidString: id) ?? UUID()
        self.type = type
        self.refID = refID
        self.itemID = itemID
        self.label = label
        self.isPremium = isPremium == 1
        self.recordID = record.recordID
    }
    
    // Convert to CKRecord
    func toCKRecord() -> CKRecord {
        let record = recordID.map { CKRecord(recordType: "UnlockableItem", recordID: $0) } 
                     ?? CKRecord(recordType: "UnlockableItem")
        
        record["id"] = id.uuidString as CKRecordValue
        record["type"] = type as CKRecordValue
        record["ref_id"] = refID as CKRecordValue
        record["item_id"] = itemID as CKRecordValue
        record["label"] = label as CKRecordValue
        record["is_premium"] = (isPremium ? 1 : 0) as CKRecordValue
        
        return record
    }
}
