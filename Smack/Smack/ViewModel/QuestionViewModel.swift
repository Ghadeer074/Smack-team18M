//
//  QuestionViewModel.swift
//  Smack
//

import Foundation

@MainActor
@Observable
class QuestionViewModel {

    var questionText: String = ""
    var answer: String = ""
    var timeRemaining: Int = 30
    var isLoading = false
    var answerSubmitted = false
    var errorMessage: String?

    private var timerTask: Task<Void, Never>?

    func loadQuestion(sessionQuestion: sessionQuestionModel) async {
        isLoading = true
        do {
            // ── جيب كل الأسئلة وفلتر محلياً بدون query على id ──
            let allQuestions: [QuestionModel] = try await CloudKitManager.shared.fetch(
                recordType: "Question",
                predicate: NSPredicate(value: true)
            )
            if let found = allQuestions.first(where: { $0.id == sessionQuestion.questionID }) {
                questionText = found.prompt
            } else {
                questionText = allQuestions.first?.prompt ?? "تعذر تحميل السؤال"
            }
        } catch {
            questionText = "تعذر تحميل السؤال: \(error.localizedDescription)"
        }
        isLoading = false
        startTimer()
    }

    func submitAnswer(sessionQuestionID: UUID, playerID: UUID) async {
        let finalAnswer = answer.trimmingCharacters(in: .whitespaces).isEmpty ? "معرفش" : answer
        isLoading = true
        do {
            _ = try await CloudKitManager.shared.submitAnswer(
                sessionQuestionID: sessionQuestionID,
                playerID: playerID,
                content: finalAnswer
            )
            timerTask?.cancel()
            answerSubmitted = true
        } catch {
            errorMessage = "تعذر إرسال الإجابة: \(error.localizedDescription)"
        }
        isLoading = false
    }

    private func startTimer() {
        timerTask?.cancel()
        timeRemaining = 30
        timerTask = Task {
            while timeRemaining > 0 && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                timeRemaining -= 1
            }
            if !answerSubmitted && timeRemaining == 0 {
                answer = "معرفش"
            }
        }
    }

    func stopTimer() {
        timerTask?.cancel()
    }
}
