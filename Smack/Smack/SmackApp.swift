//
//  SmackApp.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 17/11/1447 AH.
//


import SwiftUI

@main
struct SmackApp: App {

    @State private var nav = NavigationManager()

    init() {
        AudioManager.shared.playMusic("GameMusic")
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $nav.path) {

                SplashScreen()
                    .navigationBarHidden(true)
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {

                        case .joinOrHost:
                            JoinOrHostScreen()

                        case .enterCode:
                            EnterCodeScreen()

                        case .gameSettings:
                            GameSettingsScreen()

                        case .characterCustomization:
                            CharacterCustomizationScreen()

                        case .waitingGameRoom:
                            WaitingGameRoomScreen()

                        case .playerOrVoter:
                            PlayerOrVoterScreen()

                        case .playerWaiting:
                            PlayerWaitingScreen()

                        case .votersWaiting:
                            VotersWaitingScreen()

                        case .question:
                            QuestionScreen()

                        case .votingScreen:
                            VotingScreen()

                        case .roundWinner:
                            RoundWinner()

                        case .drawScreen:
                            DrawScreen()

                        case .gameWinner:
                            GameWinner()

                        case .settings:
                            SettingsScreen()

                        case .subscription:
                            SubscriptionPageScreen()
                        }
                    }
            }
            .environment(nav)
        }
    }
}
