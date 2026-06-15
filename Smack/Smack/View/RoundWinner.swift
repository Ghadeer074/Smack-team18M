//
//  RoundWinner.swift
//  Smack
//
import SwiftUI
import CloudKit

struct RoundWinner: View {

    @Environment(NavigationManager.self) private var nav
    @State private var vm = RoundWinnerViewModel()
    @State private var move = false
    @State private var titleVisible = false
    @State private var bubbleVisible = false
    @State private var characterVisible = false
    @State private var countdown = 6

    var body: some View {
        ZStack {
            Color(.blue).ignoresSafeArea()

            GeometryReader { geo in
                VStack(spacing: geo.size.height * 0.04) {

                    TextTitle(
                        text: vm.isLastRound ? "انتهت اللعبة! 🏆" : "أطلق شطحة في الجولة!",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.1,
                        strokeWidth: 2,
                        color: Color(.yellow)
                    )
                    .frame(width: geo.size.width * 0.9)
                    .multilineTextAlignment(.center)
                    .rotationEffect(.degrees(-2))
                    .padding(.top, geo.size.height * 0.08)
                    .scaleEffect(titleVisible ? 1 : 0)
                    .animation(.spring(duration: 0.5), value: titleVisible)

                    ZStack {
                        ButtonView(width: geo.size.width * 0.85, height: geo.size.height * 0.15,
                                   fillColor: .white, borderColor: Color(.red), shadowWidth: 6)
                        if vm.isLoading {
                            ProgressView().tint(.black)
                        } else {
                            Text(vm.winnerAnswer.isEmpty ? "..." : vm.winnerAnswer)
                                .font(.custom("Tajawal-Black", size: geo.size.width * 0.055))
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.center)
                                .lineSpacing(8)
                                .frame(width: geo.size.width * 0.7)
                        }
                    }
                    .opacity(bubbleVisible ? 1 : 0)
                    .offset(y: bubbleVisible ? 0 : -geo.size.height * 0.05)
                    .animation(.easeOut(duration: 0.5), value: bubbleVisible)
                    .padding(.bottom, geo.size.height * 0.02)

                    Image("Character")
                        .resizable().scaledToFit()
                        .frame(width: geo.size.width * 0.6)
                        .rotationEffect(.degrees(move ? 4 : -4))
                        .offset(y: move ? -8 : 0)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: move)
                        .opacity(characterVisible ? 1 : 0)
                        .scaleEffect(characterVisible ? 1 : 0.6)
                        .animation(.spring(duration: 0.5), value: characterVisible)

                    Spacer()

                    ZStack {
                        ButtonView(width: geo.size.width * 0.55, height: geo.size.height * 0.085,
                                   fillColor: Color(.red), borderColor: .black, shadowWidth: 5)
                        Text(vm.winnerName.isEmpty ? "..." : vm.winnerName)
                            .font(.custom("Tajawal-Black", size: geo.size.width * 0.08))
                            .foregroundStyle(.white)
                    }
                    .opacity(characterVisible ? 1 : 0)

                    if !vm.isLoading {
                        TextTitle(
                            text: "الانتقال بعد \(countdown)ث",
                            fontName: "Lalezar-Regular",
                            size: geo.size.width * 0.055,
                            strokeWidth: 0.5,
                            color: .white
                        )
                        .padding(.bottom, geo.size.height * 0.04)
                    }

                }.frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            titleVisible = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { bubbleVisible = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { characterVisible = true; move.toggle() }

            Task {
                if let question = nav.currentSessionQuestion,
                   let session = nav.currentSession {
                    await vm.loadRoundWinner(
                        sessionQuestion: question,
                        session: session,
                        totalRounds: nav.totalRounds
                    )
                }
                // ── العداد يبدأ بعد ما يخلص التحميل ──
                startCountdown()
            }
        }
    }

    private func startCountdown() {
        countdown = 6
        Task {
            while countdown > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                countdown -= 1
            }
            await navigate()
        }
    }

    private func navigate() async {
        // ── لو آخر جولة روح للفائز الكلي ──
        if vm.isLastRound {
            nav.push(.gameWinner)
            return
        }

        guard let session = nav.currentSession,
              let currentQuestion = nav.currentSessionQuestion else { return }

        let nextRound = currentQuestion.roundNumber + 1

        // ── الهوست فقط ينشئ السؤال الجديد ──
        if nav.isHost {
            await createNextQuestion(session: session, nextRound: nextRound)
        }

        // ── كل الجوالات تنتظر السؤال الجديد ──
        await waitForNextQuestion(session: session, nextRound: nextRound)
    }

    private func createNextQuestion(session: sessionModel, nextRound: Int) async {
        do {
            let all: [QuestionModel] = try await CloudKitManager.shared.fetch(
                recordType: "Question", predicate: NSPredicate(value: true)
            )
            let currentQID = nav.currentSessionQuestion?.questionID
            let others = all.filter { $0.id != currentQID }
            guard let nextQuestion = others.randomElement() ?? all.randomElement() else { return }

            let container = CKContainer(identifier: "iCloud.com.Smack")
            let record = CKRecord(recordType: "SessionQuestion")
            record["id"] = UUID().uuidString as CKRecordValue
            record["session_id"] = session.id.uuidString as CKRecordValue
            record["question_id"] = nextQuestion.id.uuidString as CKRecordValue
            record["round_number"] = nextRound as CKRecordValue
            record["was_answerd"] = 0 as CKRecordValue
            // ── نحفظ عدد الجولات الكلي في كل سؤال ──
            record["total_rounds"] = nav.totalRounds as CKRecordValue
            try await container.publicCloudDatabase.save(record)
        } catch {
            print("❌ createNextQuestion: \(error)")
        }
    }

    private func waitForNextQuestion(session: sessionModel, nextRound: Int) async {
        for _ in 0..<15 {
            do {
                let predicate = NSPredicate(format: "session_id == %@", session.id.uuidString)
                let all: [sessionQuestionModel] = try await CloudKitManager.shared.fetch(
                    recordType: "SessionQuestion", predicate: predicate
                )
                if let next = all.first(where: { $0.roundNumber == nextRound }) {
                    nav.currentSessionQuestion = next
                    nav.currentQuestionText = ""
                    if nav.selectedRole == "voter" && !nav.isHost {
                        nav.push(.votersWaiting)
                    } else {
                        nav.push(.question)
                    }
                    return
                }
            } catch {}
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
    }
}

#Preview { RoundWinner().environment(NavigationManager()) }
