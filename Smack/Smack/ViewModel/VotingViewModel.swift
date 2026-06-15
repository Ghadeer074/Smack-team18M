//
//  VotingViewModel.swift
//  Smack
//

import Foundation

@MainActor
@Observable
class VotingViewModel {

    var answers: [AnswerModel] = []
    var isLoading = false
    var voteSubmitted = false
    var errorMessage: String?
    var timeRemaining: Int = 30

    private var timerTask: Task<Void, Never>?
    private var pollingTask: Task<Void, Never>?

    func loadAnswers(sessionQuestionID: UUID) async {
        isLoading = true
        // ── polling كل ثانيتين للإجابات ──
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                do {
                    let fetched = try await CloudKitManager.shared.fetchAnswers(
                        forSessionQuestion: sessionQuestionID
                    )
                    if !fetched.isEmpty {
                        answers = fetched
                        isLoading = false
                    }
                } catch {}
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
        startTimer()
    }

    func submitVote(sessionQuestionID: UUID, answerID: UUID) async {
        guard !voteSubmitted else { return }
        isLoading = true
        do {
            // ── نستخدم deviceID كـ voterID عشان المصوت ما عنده player ──
            let voterID = DeviceManager.shared.deviceID
            _ = try await CloudKitManager.shared.submitVote(
                sessionQuestionID: sessionQuestionID,
                voterID: voterID,
                answerID: answerID
            )
            timerTask?.cancel()
            pollingTask?.cancel()
            voteSubmitted = true
        } catch {
            errorMessage = "تعذر إرسال التصويت"
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
            if !voteSubmitted {
                pollingTask?.cancel()
                voteSubmitted = true
            }
        }
    }

    func stopAll() {
        timerTask?.cancel()
        pollingTask?.cancel()
    }
}
