//
//  PlayerOrVoterScreen.swift
//  Smack
//
import SwiftUI
import CloudKit

struct PlayerOrVoterScreen: View {

    enum Choice { case player, voter }

    @Environment(NavigationManager.self) private var nav
    @State var userChoice: Choice?
    @State private var move = false
    @State private var playerCount = 0
    @State private var isLoading = true
    @State private var pollingTask: Task<Void, Never>? = nil

    var playerLocked: Bool { playerCount >= 2 }

    var body: some View {
        ZStack {
            Color(.blue).ignoresSafeArea()

            GeometryReader { geo in

                Image("TinyCharacter")
                    .resizable().scaledToFit()
                    .frame(width: geo.size.width * 0.7)
                    .rotationEffect(.degrees(-140))
                    .position(x: geo.size.width * 0.9, y: geo.size.height * -0.03)
                    .offset(y: move ? -8 : 1)
                    .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true), value: move)
                    .onAppear { move.toggle() }

                VStack {
                    TextTitle(text: "حدد موقعك!", fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.11, strokeWidth: 2, color: Color(.yellow))

                    if isLoading {
                        ProgressView().tint(.white).scaleEffect(2).padding()
                    } else {

                        // ── player ──
                        Button {
                            if !playerLocked {
                                userChoice = userChoice == .player ? nil : .player
                            }
                        } label: {
                            ZStack {
                                ButtonView(
                                    width: geo.size.width * 0.8,
                                    height: geo.size.width * 0.28,
                                    fillColor: playerLocked ? Color(.systemGray5) : .white,
                                    borderColor: userChoice == .player ? Color(.red) : (playerLocked ? Color(.systemGray3) : Color(.black))
                                )
                                PlayerOrVoterCardDesign(
                                    width: geo.size.width * 0.8,
                                    emoji: "🤾🏻",
                                    title: "لاعب",
                                    subTitle: playerLocked ? "الأماكن امتلأت 🔒" : "فاجئهم بشطحاتك !",
                                    circleColor: userChoice == .player ? Color(.red) : (playerLocked ? Color(.systemGray3) : Color(.black))
                                )
                                if playerLocked {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.black.opacity(0.15))
                                        .frame(width: geo.size.width * 0.8, height: geo.size.width * 0.28)
                                }
                            }
                        }
                        .disabled(playerLocked)

                        // ── voter ──
                        Button {
                            userChoice = userChoice == .voter ? nil : .voter
                        } label: {
                            ZStack {
                                ButtonView(
                                    width: geo.size.width * 0.8,
                                    height: geo.size.width * 0.28,
                                    borderColor: userChoice == .voter ? Color(.red) : Color(.black)
                                )
                                PlayerOrVoterCardDesign(
                                    width: geo.size.width * 0.8,
                                    emoji: "🧑🏻‍⚖️",
                                    title: "مصوّت",
                                    subTitle: "حدد الشطحة الرهيبة",
                                    circleColor: userChoice == .voter ? Color(.red) : Color(.black)
                                )
                            }
                        }

                        if playerLocked {
                            Text("اللاعبين اكتملوا — ستنضم كمصوّت")
                                .font(.custom("Tajawal-Bold", size: geo.size.width * 0.04))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.vertical)
                        }
                    }

                    Spacer().frame(height: geo.size.height * 0.25)

                    Button {
                        let finalRole = playerLocked ? "voter" : (userChoice == .player ? "player" : "voter")
                        nav.selectedRole = finalRole
                        nav.push(.characterCustomization)
                    } label: {
                        ZStack {
                            ButtonView(
                                width: geo.size.width * 0.5,
                                height: geo.size.height * 0.1,
                                fillColor: (userChoice == nil && !playerLocked) ? Color(.gray) : Color(.red)
                            )
                            Text("التالي")
                                .font(.custom("Lalezar-Regular", size: geo.size.width * 0.1))
                                .foregroundStyle(.white)
                        }
                    }
                    .disabled(userChoice == nil && !playerLocked)

                }.frame(width: geo.size.width, height: geo.size.height)

                BackButton(geo: geo)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task { await loadPlayerCount() }
            startPolling()
        }
        .onDisappear {
            pollingTask?.cancel()
        }
        .onChange(of: playerLocked) { _, locked in
            if locked { userChoice = .voter }
        }
    }

    private func startPolling() {
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await loadPlayerCount()
            }
        }
    }

    private func loadPlayerCount() async {
        guard let session = nav.currentSession else {
            isLoading = false
            return
        }
        do {
            let players = try await CloudKitManager.shared.fetchPlayers(forsession: session.id)
            playerCount = players.filter { $0.role == "player" }.count
            if playerCount >= 2 && userChoice == nil {
                userChoice = .voter
            }
        } catch {}
        isLoading = false
    }
}

struct PlayerOrVoterCardDesign: View {
    var width: CGFloat
    var emoji: String
    var title: String
    var subTitle: String
    var circleColor: Color = .black

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                Text(title)
                    .font(.custom("Lalezar-Regular", size: width * 0.1))
                    .foregroundStyle(.black)
                Text(subTitle)
                    .font(.custom("Tajawal-Bold", size: width * 0.045))
                    .foregroundStyle(.black)
            }
            Spacer().frame(width: width * 0.05)
            ZStack {
                Circle().frame(width: width * 0.2, height: width * 0.2).foregroundStyle(circleColor)
                Text(emoji).font(.system(size: width * 0.1))
            }
            Spacer().frame(width: width * 0.07)
        }
        .frame(width: width)
    }
}

#Preview {
    PlayerOrVoterScreen().environment(NavigationManager())
}
