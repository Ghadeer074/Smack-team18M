//
//  SubscriptionManager.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 25/11/1447 AH.
//

import Foundation
import CloudKit
import UserNotifications
internal import Combine
import UIKit

// Manages CloudKit subscriptions for real-time updates
@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    private let container: CKContainer
    private let publicDatabase: CKDatabase
    
    @Published var hasActiveSubscriptions = false
    
    private init() {
        container = CKContainer(identifier: "iCloud.com.Smack")
        publicDatabase = container.publicCloudDatabase
    }
    
    // MARK: - Setup
    
    func setupSubscriptions() async {
        await requestNotificationPermission()
        await registerForPushNotifications()
        await subscribeToPlayerChanges()
        await subscribeTosessionChanges()
        await subscribeToVoteChanges()
    }
    
    func removeAllSubscriptions() async {
        do {
            let subscriptions = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[CKSubscription], Error>) in
                publicDatabase.fetchAllSubscriptions { subscriptions, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let subscriptions = subscriptions {
                        continuation.resume(returning: subscriptions)
                    } else {
                        continuation.resume(returning: [])
                    }
                }
            }
            
            for subscription in subscriptions {
                try await publicDatabase.deleteSubscription(withID: subscription.subscriptionID)
            }
            
            hasActiveSubscriptions = false
            print("✅ Removed all subscriptions")
        } catch {
            print("❌ Failed to remove subscriptions: \(error)")
        }
    }
    
    // MARK: - Notification Permission
    
    private func requestNotificationPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            
            if granted {
                print("✅ Notification permission granted")
            } else {
                print("⚠️ Notification permission denied")
            }
        } catch {
            print("❌ Failed to request notification permission: \(error)")
        }
    }
    
    private func registerForPushNotifications() async {
        await UIApplication.shared.registerForRemoteNotifications()
    }
    
    // MARK: - Player Subscriptions
    
    func subscribeToPlayerChanges() async {
        let subscriptionID = "player-changes"
        
        // Predicate: all records
        let predicate = NSPredicate(value: true)
        
        // Create subscription
        let subscription = CKQuerySubscription(
            recordType: "Player",
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )
        
        // Notification info
        let notification = CKSubscription.NotificationInfo()
        notification.shouldSendContentAvailable = true
        notification.alertBody = "Player joined or updated"
        subscription.notificationInfo = notification
        
        do {
            _ = try await publicDatabase.save(subscription)
            print("✅ Subscribed to Player changes")
        } catch {
            print("❌ Failed to subscribe to Player changes: \(error)")
        }
    }
    
    // MARK: - session Subscriptions
    
    func subscribeTosessionChanges() async {
        let subscriptionID = "session-changes"
        
        let predicate = NSPredicate(value: true)
        
        let subscription = CKQuerySubscription(
            recordType: "session",
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordUpdate]
        )
        
        let notification = CKSubscription.NotificationInfo()
        notification.shouldSendContentAvailable = true
        notification.alertBody = "Game session updated"
        subscription.notificationInfo = notification
        
        do {
            _ = try await publicDatabase.save(subscription)
            print("✅ Subscribed to session changes")
        } catch {
            print("❌ Failed to subscribe to session changes: \(error)")
        }
    }
    
    // MARK: - Vote Subscriptions
    
    func subscribeToVoteChanges() async {
        let subscriptionID = "vote-changes"
        
        let predicate = NSPredicate(value: true)
        
        let subscription = CKQuerySubscription(
            recordType: "Vote",
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordCreation]
        )
        
        let notification = CKSubscription.NotificationInfo()
        notification.shouldSendContentAvailable = true
        subscription.notificationInfo = notification
        
        do {
            _ = try await publicDatabase.save(subscription)
            hasActiveSubscriptions = true
            print("✅ Subscribed to Vote changes")
        } catch {
            print("❌ Failed to subscribe to Vote changes: \(error)")
        }
    }
    
    // MARK: - Subscribe to Specific session
    
    func subscribeTosession(sessionID: UUID) async {
        let subscriptionID = "session-\(sessionID.uuidString)"
        
        // Only get updates for this specific session
        let predicate = NSPredicate(format: "id == %@", sessionID.uuidString)
        
        let subscription = CKQuerySubscription(
            recordType: "session",
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordUpdate]
        )
        
        let notification = CKSubscription.NotificationInfo()
        notification.shouldSendContentAvailable = true
        notification.alertBody = "Your game has started!"
        subscription.notificationInfo = notification
        
        do {
            _ = try await publicDatabase.save(subscription)
            print("✅ Subscribed to session: \(sessionID)")
        } catch {
            print("❌ Failed to subscribe to session: \(error)")
        }
    }
    
    func unsubscribeFromsession(sessionID: UUID) async {
        let subscriptionID = "session-\(sessionID.uuidString)"
        
        do {
            try await publicDatabase.deleteSubscription(withID: subscriptionID)
            print("✅ Unsubscribed from session: \(sessionID)")
        } catch {
            print("❌ Failed to unsubscribe from session: \(error)")
        }
    }
    
    // MARK: - Handle Remote Notifications
    
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) async {
        // Parse CloudKit notification
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) else {
            return
        }
        
        switch notification.notificationType {
        case .query:
            if let queryNotification = notification as? CKQueryNotification {
                await handleQueryNotification(queryNotification)
            }
            
        case .recordZone:
            print("📥 Record zone notification received")
            
        case .database:
            print("📥 Database notification received")
            
        @unknown default:
            print("📥 Unknown notification type")
        }
    }
    
    private func handleQueryNotification(_ notification: CKQueryNotification) async {
        guard let recordID = notification.recordID else { return }
        
        print("📥 Query notification for record: \(recordID.recordName)")
        
        // Post notification to update UI
        NotificationCenter.default.post(
            name: .cloudKitRecordChanged,
            object: nil,
            userInfo: [
                "recordID": recordID,
                "recordType": notification.recordFields?["recordType"] as? String ?? "Unknown"
            ]
        )
        
        // Handle different record types
        switch notification.subscriptionID {
        case "player-changes":
            NotificationCenter.default.post(name: .playerChanged, object: nil)
            
        case "session-changes":
            NotificationCenter.default.post(name: .sessionChanged, object: nil)
            
        case "vote-changes":
            NotificationCenter.default.post(name: .voteReceived, object: nil)
            
        default:
            if notification.subscriptionID?.starts(with: "session-") == true {
                NotificationCenter.default.post(name: .sessionChanged, object: nil)
            }
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let cloudKitRecordChanged = Notification.Name("cloudKitRecordChanged")
    static let playerChanged = Notification.Name("playerChanged")
    static let sessionChanged = Notification.Name("sessionChanged")
    static let voteReceived = Notification.Name("voteReceived")
}

// MARK: - AppDelegate Integration

extension SubscriptionManager {
    // Call this from AppDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)
    static func handleBackgroundNotification(
        _ userInfo: [AnyHashable: Any],
        completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        Task {
            await SubscriptionManager.shared.handleRemoteNotification(userInfo)
            completionHandler(.newData)
        }
    }
    
    // Call this from AppDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:)
    static func didRegisterForRemoteNotifications(deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("✅ Device token: \(tokenString)")
    }
    
    // Call this from AppDelegate.application(_:didFailToRegisterForRemoteNotificationsWithError:)
    static func didFailToRegisterForRemoteNotifications(error: Error) {
        print("❌ Failed to register for remote notifications: \(error)")
    }
}

// MARK: - Usage Example

/*
 
 في SmackApp.swift:
 
 @main
 struct SmackApp: App {
     @StateObject private var subscriptionManager = CloudKitSubscriptionManager.shared
     
     var body: some Scene {
         WindowGroup {
             ContentView()
                 .task {
                     await subscriptionManager.setupSubscriptions()
                 }
         }
     }
 }
 
 في GamesessionViewModel.swift:
 
 func joinsession(withCode code: String, username: String) async {
     // ... existing code ...
     
     // Subscribe to this specific session
     await CloudKitSubscriptionManager.shared.subscribeTosession(sessionID: foundsession.id)
     
     // Listen for updates
     NotificationCenter.default.addObserver(
         forName: .sessionChanged,
         object: nil,
         queue: .main
     ) { [weak self] _ in
         Task {
             await self?.refreshsession()
         }
     }
 }
 
 */
