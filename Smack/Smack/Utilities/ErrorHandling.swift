//
//  SmackError.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 25/11/1447 AH.
//

import Foundation
import CloudKit
import Network
internal import Combine

// Enhanced error handling for CloudKit operations
enum SmackError: LocalizedError {
    case notAuthenticated
    case networkUnavailable
    case sessionFull
    case sessionNotFound
    case sessionAlreadyStarted
    case invalidJoinCode
    case playerAlreadyJoined
    case recordNotFound
    case conversionFailed
    case quotaExceeded
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to iCloud to continue"
        case .networkUnavailable:
            return "No internet connection available"
        case .sessionFull:
            return "This game session is full"
        case .sessionNotFound:
            return "Game session not found. Check the join code."
        case .sessionAlreadyStarted:
            return "This game has already started"
        case .invalidJoinCode:
            return "Invalid join code format"
        case .playerAlreadyJoined:
            return "You have already joined this session"
        case .recordNotFound:
            return "The requested data was not found"
        case .conversionFailed:
            return "Failed to process data from server"
        case .quotaExceeded:
            return "Storage quota exceeded"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .notAuthenticated:
            return "Go to Settings → [Your Name] → iCloud and sign in"
        case .networkUnavailable:
            return "Check your internet connection and try again"
        case .sessionFull:
            return "Try creating a new game or joining a different session"
        case .sessionNotFound:
            return "Ask the host for the correct join code"
        case .sessionAlreadyStarted:
            return "Create a new game or join another session"
        case .invalidJoinCode:
            return "Join codes should be 6 characters (letters and numbers)"
        case .playerAlreadyJoined:
            return "Wait for the host to start the game"
        default:
            return "Please try again later"
        }
    }
}

// Network monitoring for offline support
@MainActor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.smack.networkmonitor")
    
    @Published var isConnected = true
    @Published var connectionType: NWInterface.InterfaceType?
    
    private init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type
                
                if path.status == .satisfied {
                    print("✅ Network connection available")
                } else {
                    print("⚠️ Network connection unavailable")
                }
            }
        }
        
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    var connectionDescription: String {
        guard isConnected else { return "Offline" }
        
        switch connectionType {
        case .wifi:
            return "WiFi"
        case .cellular:
            return "Cellular"
        case .wiredEthernet:
            return "Ethernet"
        default:
            return "Connected"
        }
    }
}

// Local cache manager for offline support
@MainActor
class LocalCacheManager: ObservableObject {
    static let shared = LocalCacheManager()
    
    private let defaults = UserDefaults.standard
    private let fileManager = FileManager.default
    
    // Cache keys
    private enum CacheKey: String {
        case lastsession
        case cachedPlayers
        case cachedQuestions
        case pendingVotes
    }
    
    private init() {}
    
    // MARK: - session Cache
    
    func cachesession(_ session: sessionModel) {
        if let encoded = try? JSONEncoder().encode(session) {
            defaults.set(encoded, forKey: CacheKey.lastsession.rawValue)
        }
    }
    
    func getCachedsession() -> sessionModel? {
        guard let data = defaults.data(forKey: CacheKey.lastsession.rawValue),
              let session = try? JSONDecoder().decode(sessionModel.self, from: data) else {
            return nil
        }
        return session
    }
    
    func clearsessionCache() {
        defaults.removeObject(forKey: CacheKey.lastsession.rawValue)
    }
    
    // MARK: - Players Cache
    
    func cachePlayers(_ players: [PlayerModel]) {
        if let encoded = try? JSONEncoder().encode(players) {
            defaults.set(encoded, forKey: CacheKey.cachedPlayers.rawValue)
        }
    }
    
    func getCachedPlayers() -> [PlayerModel]? {
        guard let data = defaults.data(forKey: CacheKey.cachedPlayers.rawValue),
              let players = try? JSONDecoder().decode([PlayerModel].self, from: data) else {
            return nil
        }
        return players
    }
    
    // MARK: - Pending Operations
    
    func queuePendingVote(_ vote: VoteModel) {
        var pendingVotes = getPendingVotes()
        pendingVotes.append(vote)
        
        if let encoded = try? JSONEncoder().encode(pendingVotes) {
            defaults.set(encoded, forKey: CacheKey.pendingVotes.rawValue)
        }
    }
    
    func getPendingVotes() -> [VoteModel] {
        guard let data = defaults.data(forKey: CacheKey.pendingVotes.rawValue),
              let votes = try? JSONDecoder().decode([VoteModel].self, from: data) else {
            return []
        }
        return votes
    }
    
    func clearPendingVotes() {
        defaults.removeObject(forKey: CacheKey.pendingVotes.rawValue)
    }
    
    // MARK: - Sync Pending Operations
    
    func syncPendingOperations() async throws {
        let pendingVotes = getPendingVotes()
        
        guard !pendingVotes.isEmpty else { return }
        
        print("🔄 Syncing \(pendingVotes.count) pending votes...")
        
        let cloudKit = CloudKitManager.shared
        
        for vote in pendingVotes {
            do {
                _ = try await cloudKit.save(vote)
                print("✅ Synced vote: \(vote.id)")
            } catch {
                print("❌ Failed to sync vote: \(error)")
                throw error
            }
        }
        
        clearPendingVotes()
        print("✅ All pending operations synced")
    }
    
    // MARK: - Clear All Cache
    
    func clearAllCache() {
        clearsessionCache()
        defaults.removeObject(forKey: CacheKey.cachedPlayers.rawValue)
        defaults.removeObject(forKey: CacheKey.cachedQuestions.rawValue)
        clearPendingVotes()
    }
}

// Retry mechanism for failed operations
actor RetryManager {
    private var retryCount: [String: Int] = [:]
    private let maxRetries = 3
    private let retryDelay: TimeInterval = 2.0
    
    func executeWithRetry<T>(
        operation: String,
        action: () async throws -> T
    ) async throws -> T {
        let currentRetries = retryCount[operation] ?? 0
        
        do {
            let result = try await action()
            retryCount[operation] = 0 // Reset on success
            return result
        } catch {
            if currentRetries < maxRetries {
                retryCount[operation] = currentRetries + 1
                print("⚠️ Retry \(currentRetries + 1)/\(maxRetries) for operation: \(operation)")
                
                try await Task.sleep(nanoseconds: UInt64(retryDelay * Double(NSEC_PER_SEC)))
                return try await executeWithRetry(operation: operation, action: action)
            } else {
                retryCount[operation] = 0 // Reset after max retries
                throw error
            }
        }
    }
    
    func reset(operation: String) {
        retryCount[operation] = nil
    }
}

// MARK: - Enhanced CloudKitManager Extension

extension CloudKitManager {
    // Save with offline support
    func saveWithOfflineSupport<T: CloudKitConvertible>(_ model: T, cacheKey: String? = nil) async throws -> T {
        let networkMonitor = await NetworkMonitor.shared
        
        // Check network connection
        guard await networkMonitor.isConnected else {
            // Cache for later sync
            print("⚠️ Offline: Queued operation for later sync")
            throw SmackError.networkUnavailable
        }
        
        // Attempt save with retry
        let retryManager = RetryManager()
        let result = try await retryManager.executeWithRetry(operation: "save-\(type(of: model))") {
            try await self.save(model)
        }
        
        return result
    }
    
    // Fetch with cache fallback
    func fetchWithCache<T: CloudKitConvertible>(
        recordType: String,
        predicate: NSPredicate = NSPredicate(value: true),
        cacheGetter: (() -> [T]?)? = nil
    ) async throws -> [T] {
        let networkMonitor = await NetworkMonitor.shared
        
        // Try fetch if online
        if await networkMonitor.isConnected {
            do {
                let results: [T] = try await fetch(recordType: recordType, predicate: predicate)
                return results
            } catch {
                print("⚠️ Fetch failed, trying cache...")
                if let cached = cacheGetter?() {
                    return cached
                }
                throw error
            }
        } else {
            // Use cache if offline
            if let cached = cacheGetter?() {
                print("📦 Using cached data (offline)")
                return cached
            }
            throw SmackError.networkUnavailable
        }
    }
}

// MARK: - Error Handling View Modifier

struct ErrorAlertModifier: ViewModifier {
    @Binding var error: SmackError?
    
    func body(content: Content) -> some View {
        content
            .alert(
                "Error",
                isPresented: .constant(error != nil),
                presenting: error
            ) { _ in
                Button("OK") {
                    error = nil
                }
            } message: { error in
                VStack(alignment: .leading) {
                    if let description = error.errorDescription {
                        Text(description)
                    }
                    if let suggestion = error.recoverySuggestion {
                        Text("\n\(suggestion)")
                            .font(.caption)
                    }
                }
            }
    }
}

extension View {
    func errorAlert(error: Binding<SmackError?>) -> some View {
        modifier(ErrorAlertModifier(error: error))
    }
}

// MARK: - Network Status View

import SwiftUI

struct NetworkStatusBanner: View {
    @ObservedObject var networkMonitor = NetworkMonitor.shared
    
    var body: some View {
        if !networkMonitor.isConnected {
            HStack {
                Image(systemName: "wifi.slash")
                Text("Offline")
                Spacer()
                Text("Some features unavailable")
                    .font(.caption)
            }
            .padding()
            .background(Color.orange.opacity(0.2))
            .foregroundColor(.orange)
        }
    }
}

// MARK: - Usage Example

/*
 
 في ViewModel:
 
 @Published var error: SmackError?
 
 func loadData() async {
     let cacheManager = LocalCacheManager.shared
     
     do {
         let players = try await cloudKit.fetchWithCache(
             recordType: "Player",
             cacheGetter: { cacheManager.getCachedPlayers() }
         )
         
         self.players = players
         cacheManager.cachePlayers(players)
         
     } catch let error as SmackError {
         self.error = error
     } catch {
         self.error = .unknown(error)
     }
 }
 
 في View:
 
 struct GameView: View {
     @StateObject var viewModel = GameViewModel()
     
     var body: some View {
         VStack {
             NetworkStatusBanner()
             // ... content ...
         }
         .errorAlert(error: $viewModel.error)
     }
 }
 
 */
