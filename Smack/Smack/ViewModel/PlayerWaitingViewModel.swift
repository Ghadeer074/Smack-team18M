//
//  PlayerWaitingViewModel.swift
//  Smack
//

import Foundation

@MainActor
@Observable
class PlayerWaitingViewModel {

    var readyToVote: Bool = false
    var timeRemaining: Int = 30
    private var timerTask: Task<Void, Never>?

    // ── startTime يجي من وقت إنشاء الـ SessionQuestion عشان كل الجوالات تتزامن ──
    func startWaiting(questionCreatedAt: Date) {
        // ── احسب كم ثانية مضت من إنشاء السؤال ──
        let elapsed = Int(Date().timeIntervalSince(questionCreatedAt))
        let waitDuration = 30 // 30 ثانية كلية
        let remaining = max(waitDuration - elapsed, 3)

        timeRemaining = remaining
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
