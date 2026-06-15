//
//  VotingScreen.swift
//  Smack
//
import SwiftUI

struct VotingScreen: View {

    @Environment(NavigationManager.self) private var nav
    @State private var answers: [AnswerModel] = []
    @State private var voteSubmitted = false
    @State private var isLoading = false
    @State private var move = false
    @State private var bounce1 = false
    @State private var bounce2 = false
    @State private var timeRemaining = 15
    @State private var timerTask: Task<Void, Never>? = nil

    var isVoter: Bool { nav.selectedRole == "voter" && !nav.isHost }

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

                VStack(spacing: geo.size.height * 0.02) {

                    HStack {
                        TextTitle(
                            text: String(format: "00:%02d", timeRemaining),
                            fontName: "Lalezar-Regular",
                            size: geo.size.width * 0.1,
                            strokeWidth: 1,
                            color: timeRemaining <= 5 ? .red : .yellow
                        )
                        Spacer()
                        TextTitle(
                            text: isVoter ? "صوّت للأفضل!" : "الإجابة الشاطحة؟",
                            fontName: "Lalezar-Regular",
                            size: geo.size.width * 0.08,
                            strokeWidth: 1,
                            color: .yellow
                        )
                    }
                    .padding(.horizontal, geo.size.width * 0.05)
                    .padding(.top, geo.size.height * 0.05)

                    if answers.isEmpty {
                        ProgressView().tint(.white).scaleEffect(2)
                            .padding(.top, geo.size.height * 0.15)
                        Text("جاري تحميل الإجابات...")
                            .font(.custom("Tajawal-Black", size: geo.size.width * 0.05))
                            .foregroundStyle(.white)
                    } else {
                        Button {
                            guard isVoter else { return }
                            Task { await submitVote(answerID: answers[0].id) }
                        } label: {
                            ZStack {
                                ButtonView(
                                    width: geo.size.width * 0.8,
                                    height: geo.size.height * 0.2,
                                    fillColor: (voteSubmitted && isVoter) ? Color(.systemGray4) : .white
                                )
                                Text(answers[0].content)
                                    .font(.custom("Tajawal-Black", size: geo.size.width * 0.06))
                                    .foregroundStyle(.black)
                                    .multilineTextAlignment(.center)
                                    .frame(width: geo.size.width * 0.7)
                            }
                        }
                        .rotationEffect(.degrees(-3))
                        .offset(x: bounce1 ? 3 : -3, y: bounce1 ? -5 : 0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: bounce1)
                        .disabled(!isVoter || voteSubmitted)

                        if answers.count >= 2 {
                            Image("VS").resizable().scaledToFit()
                                .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.1)

                            Button {
                                guard isVoter else { return }
                                Task { await submitVote(answerID: answers[1].id) }
                            } label: {
                                ZStack {
                                    ButtonView(
                                        width: geo.size.width * 0.8,
                                        height: geo.size.height * 0.2,
                                        fillColor: (voteSubmitted && isVoter) ? Color(.systemGray4) : .white
                                    )
                                    Text(answers[1].content)
                                        .font(.custom("Tajawal-Black", size: geo.size.width * 0.06))
                                        .foregroundStyle(.black)
                                        .multilineTextAlignment(.center)
                                        .frame(width: geo.size.width * 0.7)
                                }
                            }
                            .rotationEffect(.degrees(3))
                            .offset(x: bounce2 ? -3 : 3, y: bounce2 ? -5 : 0)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: bounce2)
                            .disabled(!isVoter || voteSubmitted)
                        }
                    }

                    Spacer()
                }.frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            bounce1 = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { bounce2 = true }
            Task {
                await loadAnswers()
                startTimer()
            }
        }
        .onDisappear { timerTask?.cancel() }
        .onChange(of: timeRemaining) { _, t in
            if t <= 0 { nav.push(.roundWinner) }
        }
    }

    private func startTimer() {
        timerTask?.cancel()
        // ── التصويت يبدأ بعد 30 ثانية من إنشاء السؤال ──
        let createdAt = nav.currentSessionQuestion?.createdAt ?? Date()
        let elapsed = max(0, Int(Date().timeIntervalSince(createdAt)))
        let votingElapsed = elapsed - 30
        timeRemaining = max(15 - votingElapsed, 1)

        timerTask = Task {
            while timeRemaining > 0 && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                timeRemaining -= 1
            }
        }
    }

    private func loadAnswers() async {
        guard let question = nav.currentSessionQuestion else { return }
        for _ in 0..<8 {
            do {
                let fetched = try await CloudKitManager.shared.fetchAnswers(forSessionQuestion: question.id)
                if !fetched.isEmpty { answers = fetched; return }
            } catch {}
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
    }

    private func submitVote(answerID: UUID) async {
        guard !voteSubmitted, let question = nav.currentSessionQuestion else { return }
        do {
            let voterID = DeviceManager.shared.deviceID
            _ = try await CloudKitManager.shared.submitVote(
                sessionQuestionID: question.id,
                voterID: voterID,
                answerID: answerID
            )
            voteSubmitted = true
        } catch {}
    }
}

#Preview { VotingScreen() }
