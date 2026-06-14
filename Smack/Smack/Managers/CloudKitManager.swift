//
//  CloudKitManager.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 25/11/1447 AH.
//

import Foundation
import CloudKit
internal import Combine

@MainActor
class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    private let container: CKContainer
    private let publicDatabase: CKDatabase
    private let privateDatabase: CKDatabase
    
    @Published var isSignedInToiCloud = false
    @Published var error: Error?
    
    private init() {
        container = CKContainer(identifier: "iCloud.com.Smack")
        publicDatabase = container.publicCloudDatabase
        privateDatabase = container.privateCloudDatabase
        
        Task {
            await checkiCloudStatus()
        }
    }
    
    // MARK: - iCloud Status
    
    func checkiCloudStatus() async {
        do {
            let status = try await container.accountStatus()
            isSignedInToiCloud = (status == .available)
        } catch {
            self.error = error
            isSignedInToiCloud = false
            print("❌ iCloud account status error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Generic CRUD Operations
    
    func save<T>(_ model: T) async throws -> T where T: CloudKitConvertible {
        let record = model.toCKRecord()
        let savedRecord = try await publicDatabase.save(record)
        guard let savedModel = T(from: savedRecord) else {
            throw CloudKitError.conversionFailed
        }
        return savedModel
    }
    
    func fetch<T>(recordType: String, predicate: NSPredicate = NSPredicate(value: true)) async throws -> [T] where T: CloudKitConvertible {
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        var results: [T] = []
        let (matchResults, _) = try await publicDatabase.records(matching: query)
        
        for (_, result) in matchResults {
            switch result {
            case .success(let record):
                if let model = T(from: record) {
                    results.append(model)
                }
            case .failure(let error):
                print("❌ Error fetching record: \(error)")
            }
        }
        
        return results
    }
    
    func delete(recordID: CKRecord.ID) async throws {
        try await publicDatabase.deleteRecord(withID: recordID)
    }
    
    // MARK: - session Operations
    
    func createsession(joinCode: String, maxPlayers: Int = 8) async throws -> sessionModel {
        let session = sessionModel(
            joinCode: joinCode,
            status: "waiting",
            maxPlayers: maxPlayers
        )
        return try await save(session)
    }
    
    func fetchsession(byJoinCode code: String) async throws -> sessionModel? {
        let predicate = NSPredicate(format: "join_code == %@", code)
        let sessions: [sessionModel] = try await fetch(recordType: "session", predicate: predicate)
        return sessions.first
    }
    
    func updatesessionStatus(sessionID: UUID, status: String) async throws {
        let predicate = NSPredicate(format: "id == %@", sessionID.uuidString)
        let sessions: [sessionModel] = try await fetch(recordType: "session", predicate: predicate)
        
        guard var session = sessions.first else {
            throw CloudKitError.recordNotFound
        }
        
        session.status = status
        _ = try await save(session)
    }
    
    // MARK: - Player Operations
    
    func addPlayer(
        sessionID: UUID,
        deviceID: UUID,
        username: String,
        isHost: Bool = false
    ) async throws -> PlayerModel {
        let player = PlayerModel(
            sessionID: sessionID,
            deviceID: deviceID,
            generatedUsername: username,
            role: isHost ? "host" : "player",
            isHost: isHost
        )
        return try await save(player)
    }
    
    func fetchPlayers(forsession sessionID: UUID) async throws -> [PlayerModel] {
        let predicate = NSPredicate(format: "session_id == %@", sessionID.uuidString)
        return try await fetch(recordType: "Player", predicate: predicate)
    }
    
    func updatePlayerPoints(playerID: UUID, points: Int) async throws {
        let predicate = NSPredicate(format: "id == %@", playerID.uuidString)
        let players: [PlayerModel] = try await fetch(recordType: "Player", predicate: predicate)
        
        guard var player = players.first else {
            throw CloudKitError.recordNotFound
        }
        
        player.points = points
        _ = try await save(player)
    }
    
    // MARK: - Question Operations
    
    func fetchUnansweredQuestions(forSession sessionID: UUID) async throws -> [sessionQuestionModel] {
        let predicate = NSPredicate(format: "session_id == %@ AND was_answered == %d", sessionID.uuidString, 0)
        return try await fetch(recordType: "SessionQuestion", predicate: predicate)
    }
    
    func fetchQuestions(forCategory categoryID: UUID) async throws -> [QuestionModel] {
        let predicate = NSPredicate(format: "category_id == %@", categoryID.uuidString)
        return try await fetch(recordType: "Question", predicate: predicate)
    }
    
    func fetchFreeQuestions() async throws -> [QuestionModel] {
        let predicate = NSPredicate(format: "is_free == %d", 1)
        return try await fetch(recordType: "Question", predicate: predicate)
    }
    
    // MARK: - Vote Operations
    
    func submitVote(
        sessionQuestionID: UUID,
        voterID: UUID,
        votedForID: UUID
    ) async throws -> VoteModel {
        let vote = VoteModel(
            sessionQuestionID: sessionQuestionID,
            voterParticipantID: voterID,
            votedForParticipantID: votedForID
        )
        return try await save(vote)
    }
    
    func fetchVotes(forsessionQuestion sessionQuestionID: UUID) async throws -> [VoteModel] {
        let predicate = NSPredicate(format: "session_question_id == %@", sessionQuestionID.uuidString)
        return try await fetch(recordType: "Vote", predicate: predicate)
    }
    
    func fetchVotes(forPlayer playerID: UUID) async throws -> [VoteModel] {
        let predicate = NSPredicate(format: "voted_for_participant_id == %@", playerID.uuidString)
        return try await fetch(recordType: "Vote", predicate: predicate)
    }
    
    // MARK: - Category Operations
    
    func fetchAllCategories() async throws -> [CategoryModel] {
        return try await fetch(recordType: "Category")
    }
    
    func fetchFreeCategories() async throws -> [CategoryModel] {
        let predicate = NSPredicate(format: "is_free == %d", 1)
        return try await fetch(recordType: "Category", predicate: predicate)
    }
    
    // MARK: - Device Operations
    
    func registerDevice() async throws -> DeviceModel {
        let device = DeviceModel()
        return try await save(device)
    }
    
    // MARK: - Subscription Operations
    
    func saveSubscription(
        deviceID: UUID,
        transactionID: String,
        expiresAt: Date
    ) async throws -> SubscriptionModel {
        let subscription = SubscriptionModel(
            deviceID: deviceID,
            storeTransactionID: transactionID,
            expiresAt: expiresAt
        )
        return try await save(subscription)
    }
    
    func checkActiveSubscription(deviceID: UUID) async throws -> Bool {
        let predicate = NSPredicate(format: "device_id == %@ AND expires_at > %@", 
                                    deviceID.uuidString, 
                                    Date() as NSDate)
        let subscriptions: [SubscriptionModel] = try await fetch(recordType: "Subscription", predicate: predicate)
        return !subscriptions.isEmpty
    }
    
    // MARK: - Purchase Operations
    
    func recordPurchase(
        deviceID: UUID,
        unlockableItemID: UUID,
        transactionID: String
    ) async throws -> PurchaseModel {
        let purchase = PurchaseModel(
            deviceID: deviceID,
            unlockableItemID: unlockableItemID,
            storeTransactionID: transactionID
        )
        return try await save(purchase)
    }
    
    func fetchUserPurchases(deviceID: UUID) async throws -> [PurchaseModel] {
        let predicate = NSPredicate(format: "device_id == %@", deviceID.uuidString)
        return try await fetch(recordType: "Purchase", predicate: predicate)
    }
    
    // MARK: - UnlockableItem Operations
    func fetchUnlockableItems(isPremium: Bool) async throws -> [UnlockableItemModel] {
        let predicate = NSPredicate(format: "is_premium == %d", isPremium ? 1 : 0)
        return try await self.fetch(recordType: "UnlockableItem", predicate: predicate)
    }

    func fetchUnlockableItems(byType type: String) async throws -> [UnlockableItemModel] {
        let predicate = NSPredicate(format: "type == %@", type)
        return try await self.fetch(recordType: "UnlockableItem", predicate: predicate)
    }
}


// MARK: - Protocol for CloudKit Conversion

protocol CloudKitConvertible {
    init?(from record: CKRecord)
    func toCKRecord() -> CKRecord
}

// MARK: - Conform all models to protocol

extension DeviceModel: CloudKitConvertible {}
extension PlayerModel: CloudKitConvertible {}
extension sessionModel: CloudKitConvertible {}
extension CategoryModel: CloudKitConvertible {}
extension QuestionModel: CloudKitConvertible {}
extension sessionQuestionModel: CloudKitConvertible {}
extension VoteModel: CloudKitConvertible {}
extension SubscriptionModel: CloudKitConvertible {}
extension UnlockableItemModel: CloudKitConvertible {}
extension PurchaseModel: CloudKitConvertible {}

// MARK: - Custom Errors

enum CloudKitError: LocalizedError {
    case conversionFailed
    case recordNotFound
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .conversionFailed:
            return "Failed to convert CloudKit record"
        case .recordNotFound:
            return "Record not found"
        case .unauthorized:
            return "Not signed in to iCloud"
        }
    }
}

