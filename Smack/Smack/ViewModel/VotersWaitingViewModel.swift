//
//  VotersWaitingViewModel.swift
//  Smack
//

import Foundation

@MainActor
@Observable
class VotersWaitingViewModel {

    var questionText: String = ""
    var readyToVote: Bool = false
    var timeRemaining: Int = 30
    private var timerTask: Task<Void, Never>?

    func start(sessionQuestion: sessionQuestionModel) async {
        await loadQuestionText(questionID: sessionQuestion.questionID)

        // ── احسب الوقت المتبقي بناءً على وقت إنشاء السؤال ──
        let elapsed = Int(Date().timeIntervalSince(sessionQuestion.createdAt ?? Date()))
        let remaining = max(30 - elapsed, 3)
        timeRemaining = remaining

        startTimer()
    }

    private func loadQuestionText(questionID: UUID) async {
        do {
            let allQuestions: [QuestionModel] = try await CloudKitManager.shared.fetch(
                recordType: "Question",
                predicate: NSPredicate(value: true)
            )
            questionText = allQuestions.first(where: { $0.id == questionID })?.prompt ?? ""
        } catch {}
    }

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task {
            while timeRemaining > 0 && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                timeRemaining -= 1
            }
            readyToVote = true
        }
    }

    func stopTimer() { timerTask?.cancel() }
}
