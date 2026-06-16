//
//  QuestionScreen.swift
//  Smack
//
import SwiftUI

struct QuestionScreen: View {

    @Environment(NavigationManager.self) private var nav
    @State private var answer = ""
    @State private var submitted = false
    @State private var isLoading = false
    @State private var move = false
    @State private var timeRemaining = 30
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var pollingTask: Task<Void, Never>? = nil

    var body: some View {
        ZStack {
            Color(.blue).ignoresSafeArea()

            GeometryReader { geo in

                Image("TinyCharacter")
                    .resizable().scaledToFit()
                    .frame(width: geo.size.width * 0.7)
                    .position(x: geo.size.width * 0.3, y: geo.size.height * 0.25)
                    .offset(y: move ? -5 : 0)
                    .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true), value: move)
                    .onAppear { move.toggle() }

                TextTitle(
                    text: String(format: "00:%02d", timeRemaining),
                    fontName: "Lalezar-Regular",
                    size: geo.size.width * 0.12,
                    strokeWidth: 1,
                    color: timeRemaining <= 10 ? Color(.red) : Color(.yellow)
                )
                .position(x: geo.size.width * 0.5, y: geo.size.height * 0.07)

                VStack(spacing: geo.size.height * 0.04) {
                    Spacer().frame(height: geo.size.height * 0.12)

                    ZStack {
                        ButtonView(width: geo.size.width * 0.85, height: geo.size.height * 0.22, borderColor: Color(.red))
                        Text(nav.currentQuestionText.isEmpty ? "جاري تحميل السؤال..." : nav.currentQuestionText)
                            .font(.custom("Tajawal-Black", size: geo.size.width * 0.06))
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                            .lineSpacing(10)
                            .frame(width: geo.size.width * 0.75)
                            .padding()
                    }

                    ZStack {
                        ButtonView(width: geo.size.width * 0.75, height: geo.size.height * 0.2)
                        ZStack(alignment: .topTrailing) {
                            if answer.isEmpty {
                                Text("اكتب ردك هنا...")
                                    .font(.custom("Tajawal-Bold", size: geo.size.width * 0.05))
                                    .foregroundStyle(.gray)
                                    .padding(.top, 8).padding(.trailing, 8)
                            }
                            TextEditor(text: $answer)
                                .font(.custom("Tajawal-Bold", size: geo.size.width * 0.06))
                                .foregroundStyle(.black)
                                .frame(width: geo.size.width * 0.65, height: geo.size.height * 0.15)
                                .scrollContentBackground(.hidden)
                                .multilineTextAlignment(.trailing)
                        }
                        .frame(width: geo.size.width * 0.65, height: geo.size.height * 0.15)
                    }

                    Button {
                        Task { await submitAnswer() }
                    } label: {
                        ZStack {
                            ButtonView(
                                width: geo.size.width * 0.45,
                                height: geo.size.height * 0.1,
                                fillColor: Color(.red)
                            )
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text(submitted ? "تم ✓" : "اشطح !")
                                    .font(.custom("Lalezar-Regular", size: geo.size.width * 0.09))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .disabled(submitted || isLoading)

                }.frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await loadQuestion()
                startTimer()
                startPolling()
            }
        }
        .onDisappear {
            timerTask?.cancel()
            pollingTask?.cancel()
        }
        .onChange(of: timeRemaining) { _, t in
            if t <= 0 {
                Task {
                    if !submitted {
                        if answer.isEmpty { answer = "معرفش" }
                        await submitAnswer()
                    }
                    goToVoting()
                }
            }
        }
    }

    // ── polling: لما الاثنين يجاوبون ينتقل فوراً ──
    private func startPolling() {
        guard let question = nav.currentSessionQuestion,
              let session = nav.currentSession else { return }

        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                do {
                    let answers = try await CloudKitManager.shared.fetchAnswers(forSessionQuestion: question.id)
                    let players = try await CloudKitManager.shared.fetchPlayers(forsession: session.id)
                    let playerCount = players.filter { $0.role == "player" }.count
                    if answers.count >= playerCount && playerCount > 0 {
                        pollingTask?.cancel()
                        timerTask?.cancel()
                        goToVoting()
                        return
                    }
                } catch {}
            }
        }
    }

    private func goToVoting() {
        nav.push(.votingScreen)
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
        guard nav.currentQuestionText.isEmpty else { return }
        do {
            let all: [QuestionModel] = try await CloudKitManager.shared.fetch(
                recordType: "Question", predicate: NSPredicate(value: true)
            )
            if let found = all.first(where: { $0.id == question.questionID }) {
                nav.currentQuestionText = found.prompt
            }
        } catch {}
    }

    private func submitAnswer() async {
        guard !submitted,
              let question = nav.currentSessionQuestion,
              let playerID = nav.currentPlayer?.id else { return }
        isLoading = true
        let finalAnswer = answer.trimmingCharacters(in: .whitespaces).isEmpty ? "معرفش" : answer
        do {
            _ = try await CloudKitManager.shared.submitAnswer(
                sessionQuestionID: question.id,
                playerID: playerID,
                content: finalAnswer
            )
            submitted = true
        } catch {}
        isLoading = false
    }
}

#Preview { QuestionScreen().environment(NavigationManager()) }
