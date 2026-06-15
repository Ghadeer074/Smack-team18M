//
//  JoinOrHostScreen.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 27/05/2026.
//

import SwiftUI

struct JoinOrHostScreen: View {

    @Environment(NavigationManager.self) private var nav
    @State private var move = false

    var body: some View {
        ZStack {
            Color(.blue).ignoresSafeArea()

            GeometryReader { geo in

                Image("TinyCharacter")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.7)
                    .rotationEffect(.degrees(25))
                    .position(x: geo.size.width * 0.1, y: geo.size.height * 1)
                    .offset(x: move ? 8 : 0, y: move ? -8 : 0)
                    .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true), value: move)
                    .onAppear { move.toggle() }

                VStack {

                    // ── انضم إلى غرفة ──
                    Button {
                        nav.push(.enterCode)
                    } label: {
                        ZStack {
                            ButtonView(width: geo.size.width * 0.8, height: geo.size.height * 0.27)
                            VStack(spacing: 1) {
                                Image("JoinAGame")
                                Text("انضم إلى غرفة")
                                    .font(.custom("Lalezar-Regular", size: geo.size.width * 0.09))
                                    .foregroundStyle(Color(.red))
                            }
                        }
                    }

                    Spacer().frame(height: geo.size.height * 0.04)

                    // ── ابدأ غرفة جديدة ← يروح على gameSettings أول ──
                    Button {
                        nav.isHost = true
                        nav.push(.gameSettings)
                    } label: {
                        ZStack {
                            ButtonView(width: geo.size.width * 0.8, height: geo.size.height * 0.27)
                            VStack(spacing: 1) {
                                Image("HostAGAME")
                                Text("ابدأ  غرفة جديدة")
                                    .font(.custom("Lalezar-Regular", size: geo.size.width * 0.09))
                                    .foregroundStyle(Color(.red))
                            }
                        }
                    }

                }.frame(width: geo.size.width, height: geo.size.height)

                BackButton(geo: geo)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    JoinOrHostScreen()
        .environment(NavigationManager())
}
