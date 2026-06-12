//
//  NavigationManager.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 12/06/2026.
//

import SwiftUI

enum AppRoute: Hashable {
    // ── onboarding ──
    case joinOrHost
    case enterCode
    case gameSettings

    // ── character ──
    case characterCustomization

    // ── host flow ──
    case waitingGameRoom

    // ── player flow ──
    case playerOrVoter
    case playerWaiting
    case votersWaiting

    // ── game ──
    case question
    case votingScreen
    case roundWinner
    case drawScreen
    case gameWinner

    // ── misc ──
    case settings
    case subscription
}

@Observable
class NavigationManager {
    var path = NavigationPath()

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
