//
//  DeviceManager.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 25/11/1447 AH.
//

import Foundation
import UIKit
internal import Combine

// Manages device identity and first-time setup
class DeviceManager: ObservableObject {
    static let shared = DeviceManager()
    
    private let deviceIDKey = "com.smack.deviceID"
    private let deviceRegisteredKey = "com.smack.deviceRegistered"
    
    @Published var deviceID: UUID
    @Published var isRegistered: Bool
    
    private init() {
        // Load or create device ID without referencing self before init completes
        let storedIDString = UserDefaults.standard.string(forKey: deviceIDKey)
        let resolvedID: UUID
        if let savedID = storedIDString, let uuid = UUID(uuidString: savedID) {
            resolvedID = uuid
        } else {
            let newID = UUID()
            UserDefaults.standard.set(newID.uuidString, forKey: deviceIDKey)
            resolvedID = newID
        }

        // Initialize stored properties
        self.deviceID = resolvedID
        self.isRegistered = UserDefaults.standard.bool(forKey: deviceRegisteredKey)
    }
    
    /// Register device with CloudKit on first launch
    func registerDeviceIfNeeded() async {
        guard !isRegistered else { return }
        
        do {
            let cloudKit = CloudKitManager.shared
            _ = try await cloudKit.registerDevice()
            
            await MainActor.run {
                self.isRegistered = true
                UserDefaults.standard.set(true, forKey: deviceRegisteredKey)
            }
            
            print("✅ Device registered: \(deviceID)")
        } catch {
            print("❌ Failed to register device: \(error.localizedDescription)")
        }
    }
    
    // Get device info for debugging
    var deviceInfo: String {
        """
        Device ID: \(deviceID)
        Model: \(UIDevice.current.model)
        System: \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)
        Registered: \(isRegistered)
        """
    }
}

