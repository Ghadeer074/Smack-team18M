//
//  WaitingGameRoomScreen.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 04/06/2026.
//
import SwiftUI

struct WaitingGameRoomScreen: View {

    @Environment(NavigationManager.self) private var nav
    @State private var vm = WaitingGameRoomViewModel()
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

                VStack(spacing: geo.size.height * 0.02) {

                    // ======= title =======
                    TextTitle(
                        text: "الغرفة جاهزة !",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.12,
                        strokeWidth: 2
                    )
                    .rotationEffect(.degrees(-2))

                    // ======= room code card =======
                    ZStack {
                        ButtonView(
                            width: geo.size.width * 0.8,
                            height: geo.size.height * 0.18,
                            borderColor: Color(.red)
                        )
                        VStack(spacing: 4) {
                            Text("كود الغرفة")
                                .font(.custom("Tajawal-Bold", size: geo.size.width * 0.05))
                                .foregroundStyle(.gray)
                                .padding()

                            Text(nav.currentSession?.joinCode ?? "----")
                                .tracking(15)
                                .font(.custom("Tajawal-Black", size: geo.size.width * 0.12))
                                .foregroundStyle(.black)
                        }
                    }

                    // ======= waiting text =======
                    TextTitle(
                        text: "ننتظر اللاعبين... (\(vm.players.count)/\(nav.currentSession?.maxPlayers ?? 0))",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.055,
                        strokeWidth: 0.5,
                        color: Color(.yellow)
                    )
                    .frame(width: geo.size.width * 0.9, alignment: .trailing)

                    // ======= players grid =======
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: geo.size.height * 0.02) {

                            ForEach(vm.players) { player in
                                VStack(spacing: 4) {
                                    ZStack {
                                        CircleView(size: geo.size.width * 0.24)
                                        Image("TinyCharacter")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: geo.size.width * 0.25)
                                    }
                                    .padding(.bottom, 2)

                                    Text(player.generatedUsername)
                                        .font(.custom("Tajawal-Black", size: geo.size.width * 0.04))
                                        .foregroundStyle(.white)

                                    if player.isHost {
                                        Text("👑")
                                            .font(.system(size: geo.size.width * 0.04))
                                    }
                                }
                            }
                        }
                        .environment(\.layoutDirection, .rightToLeft)
                        .padding(.horizontal, geo.size.width * 0.05)
                    }

                    // ======= error message =======
                    if let error = vm.errorMessage {
                        Text(error)
                            .font(.custom("Tajawal-Bold", size: geo.size.width * 0.04))
                            .foregroundStyle(Color(.red))
                    }

                    // ======= start button - للهوست فقط =======
                    if nav.isHost {
                        Button {
                            Task {
                                if let session = nav.currentSession {
                                    await vm.startGame(session: session)
                                }
                            }
                        } label: {
                            ZStack {
                                ButtonView(
                                    width: geo.size.width * 0.4,
                                    height: geo.size.height * 0.1,
                                    fillColor: Color(.red)
                                )
                                if vm.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("ابدأ !")
                                        .font(.custom("Lalezar-Regular", size: geo.size.width * 0.08))
                                        .foregroundStyle(.white)
                                }
                            }
                            .padding(.vertical)
                        }
                        .disabled(vm.players.count < 2 || vm.isLoading)
                        .opacity(vm.players.count < 2 ? 0.5 : 1)
                    }

                }.frame(width: geo.size.width, height: geo.size.height)

                // ======= back button =======
                BackButton(geo: geo)
                    .padding(.top, geo.size.height * 0.02)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if let session = nav.currentSession {
                vm.startPolling(session: session)
            }
        }
        .onDisappear {
            vm.stopPolling()
            // ── لو رجع للخلف امسح الـ player عشان يقدر يسجل من جديد ──
            if !vm.gameStarted {
                nav.currentPlayer = nil
            }
        }
        .onChange(of: vm.gameStarted) { _, started in
            if started {
                nav.currentSessionQuestion = vm.firstQuestion
                nav.totalRounds = vm.cachedTotalRounds
                if nav.selectedRole == "voter" && !nav.isHost {
                    nav.push(.votersWaiting)
                } else {
                    nav.push(.question)
                }
            }
        }
    }
}

#Preview {
    WaitingGameRoomScreen()
        .environment(NavigationManager())
}
