//
//  ContentView.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 17/11/1447 AH.
//
import SwiftUI

struct Smack: App {

    init() {
        AudioManager.shared.playMusic("GameMUsic")
    }

    var body: some Scene {
        WindowGroup {
            SplashScreen()
        }
    }
}
