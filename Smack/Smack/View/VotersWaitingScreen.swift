//
//  VotersWaitingScreen.swift
//  Smack
//
import SwiftUI

struct VotersWaitingScreen: View {

    @Environment(NavigationManager.self) private var nav
    @State private var questionText = ""
    @State private var move = false
    @State private var timeRemaining = 30
    @State private var timerTask: Task<Void, Never>? = nil

    var body: some View {
        ZStack {
            Color(.blue).ignoresSafeArea()

            GeometryReader { geo in
                VStack(spacing: geo.size.height * 0.03) {

                    TextTitle(text: "ننتظر الجواب الأفضل !",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.11,
                        strokeWidth: 2, color: .white)
                    .padding(.top, geo.size.height * 0.06)

                    ZStack {
                        ButtonView(width: geo.size.width * 0.85, height: geo.size.height * 0.2)
                        Text(questionText.isEmpty ? "جاري التحميل..." : questionText)
                            .font(.custom("Tajawal-Black", size: geo.size.width * 0.055))
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                            .frame(width: geo.size.width * 0.75)
                    }

                    Image("SplashScreen_Character")
                        .resizable().scaledToFit()
                        .frame(width: geo.size.width * 0.55)
                        .rotationEffect(.degrees(move ? 2 : 10))
                        .animation(.spring(duration: 1.8).repeatForever(autoreverses: true), value: move)
                        .onAppear { move.toggle() }

                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.yellow, lineWidth: 4))
                            .frame(width: geo.size.width * 0.7, height: geo.size.height * 0.1)

                        VStack(spacing: 2) {
                            Text("التصويت يبدأ بعد")
                                .font(.custom("Tajawal-Bold", size: geo.size.width * 0.04))
                                .foregroundStyle(.white)
                            TextTitle(text: "\(timeRemaining)ث",
                                fontName: "Lalezar-Regular",
                                size: geo.size.width * 0.1,
                                strokeWidth: 0,
                                color: timeRemaining <= 5 ? .red : .yellow)
                        }
                    }

                    Spacer()
                }.frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await loadQuestion()
                startTimer()
            }
        }
        .onDisappear { timerTask?.cancel() }
        .onChange(of: timeRemaining) { _, t in
            if t <= 0 { nav.push(.votingScreen) }
        }
    }

    private func startTimer() {
        timerTask?.cancel()
        let createdAt = nav.currentSessionQuestion?.createdAt ?? Date()
        let elapsed = max(0, Int(Date().timeIntervalSince(createdAt)))
        timeRemaining = max(30 - elapsed, 1)

        timerTask = Task {
            while timeRemaining > 0 && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                timeRemaining -= 1
            }
        }
    }

    private func loadQuestion() async {
        guard let question = nav.currentSessionQuestion else { return }
        do {
            let all: [QuestionModel] = try await CloudKitManager.shared.fetch(
                recordType: "Question", predicate: NSPredicate(value: true)
            )
            questionText = all.first(where: { $0.id == question.questionID })?.prompt ?? ""
        } catch {}
    }
}

#Preview { VotersWaitingScreen().environment(NavigationManager()) }
