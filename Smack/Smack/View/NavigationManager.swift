//
//  NavigationManager.swift
//  Smack
//

import SwiftUI

enum AppRoute: Hashable {
    case joinOrHost, enterCode, gameSettings
    case characterCustomization
    case waitingGameRoom
    case playerOrVoter, playerWaiting, votersWaiting
    case question, votingScreen, roundWinner, drawScreen, gameWinner
    case settings, subscription
}

@Observable
class NavigationManager {
    var path = NavigationPath()

    var currentSession: sessionModel?
    var currentPlayer: PlayerModel?
    var isHost: Bool = false
    var selectedRole: String = "player"
    var currentSessionQuestion: sessionQuestionModel?
    var currentQuestionText: String = ""

    // ── يتحفظ في UserDefaults عشان ما يضيع ──
    var totalRounds: Int {
        get { max(UserDefaults.standard.integer(forKey: "smack.totalRounds"), 1) }
        set { UserDefaults.standard.set(newValue, forKey: "smack.totalRounds") }
    }

    func push(_ route: AppRoute) { path.append(route) }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
        currentSession = nil
        currentPlayer = nil
        isHost = false
        selectedRole = "player"
        currentSessionQuestion = nil
        currentQuestionText = ""
    }
}
