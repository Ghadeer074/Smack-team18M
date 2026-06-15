//
//  GameWinner.swift
//  Smack
//
import SwiftUI

struct GameWinner: View {

    @Environment(NavigationManager.self) private var nav
    @State private var vm = GameWinnerViewModel()
    @State private var move = false
    @State private var titleVisible = false
    @State private var characterVisible = false
    @State private var nameVisible = false
    @State private var countdown = 8

    var body: some View {
        ZStack {
            Color(.blue).ignoresSafeArea()

            GeometryReader { geo in
                VStack(spacing: geo.size.height * 0.05) {

                    TextTitle(
                        text: "الشاطح في اللعبة 🏆",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.13,
                        strokeWidth: 1,
                        color: Color(.yellow)
                    )
                    .frame(width: geo.size.width * 0.9)
                    .multilineTextAlignment(.center)
                    .rotationEffect(.degrees(-2))
                    .padding(.top, geo.size.height * 0.07)
                    .scaleEffect(titleVisible ? 1 : 0)
                    .animation(.spring(duration: 0.5), value: titleVisible)

                    Spacer()

                    Image("Character")
                        .resizable().scaledToFit()
                        .frame(width: geo.size.width * 0.55)
                        .rotationEffect(.degrees(move ? 4 : -4))
                        .offset(y: move ? -8 : 0)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: move)
                        .opacity(characterVisible ? 1 : 0)
                        .scaleEffect(characterVisible ? 1 : 0.6)
                        .animation(.spring(duration: 0.5), value: characterVisible)

                    if vm.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        TextTitle(
                            text: vm.winnerName.isEmpty ? "..." : vm.winnerName,
                            fontName: "Tajawal-Black",
                            size: geo.size.width * 0.2,
                            strokeWidth: 3,
                            color: Color(.red)
                        )
                        .opacity(nameVisible ? 1 : 0)
                        .scaleEffect(nameVisible ? 1 : 0.5)
                        .animation(.spring(duration: 0.5), value: nameVisible)
                    }

                    Spacer()

                    // ── عداد تنازلي ──
                    TextTitle(
                        text: "الرجوع للبداية بعد \(countdown)ث",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.055,
                        strokeWidth: 0.5,
                        color: .white
                    )
                    .opacity(nameVisible ? 1 : 0)
                    .padding(.bottom, geo.size.height * 0.08)

                }.frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                if let session = nav.currentSession {
                    await vm.loadGameWinner(session: session)
                }
            }
            titleVisible = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                characterVisible = true
                move.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { nameVisible = true }
            startCountdown()
        }
    }

    private func startCountdown() {
        countdown = 8
        Task {
            while countdown > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                countdown -= 1
            }
            // ── امسح كل شي وارجع للهوم ──
            nav.popToRoot()
        }
    }
}

#Preview {
    GameWinner().environment(NavigationManager())
}
