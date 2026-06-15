//
//  GameTimerManager.swift
//  Smack
//
//  Created by Nedaa on 15/06/2026.
//

//
//  GameTimerManager.swift
//  Smack
//

import Foundation

// ── مراحل الجولة ──
enum GamePhase {
    case answering   // 0-30 ثانية: اللاعبين يكتبون
    case voting      // 30-45 ثانية: الكل يصوت
    case results     // بعد 45 ثانية: النتيجة
}

@MainActor
@Observable
class GameTimerManager {

    static let shared = GameTimerManager()

    var phase: GamePhase = .answering
    var timeRemaining: Int = 30
    var elapsed: Int = 0

    private let answerDuration = 30  // ثانية للإجابة
    private let voteDuration = 15    // ثانية للتصويت
    private var timerTask: Task<Void, Never>?

    // ── يبدأ من وقت إنشاء السؤال في CloudKit ──
    func start(from questionCreatedAt: Date) {
        timerTask?.cancel()

        timerTask = Task {
            while !Task.isCancelled {
                elapsed = Int(Date().timeIntervalSince(questionCreatedAt))

                if elapsed < answerDuration {
                    phase = .answering
                    timeRemaining = answerDuration - elapsed
                } else if elapsed < answerDuration + voteDuration {
                    phase = .voting
                    timeRemaining = (answerDuration + voteDuration) - elapsed
                } else {
                    phase = .results
                    timeRemaining = 0
                    break
                }

                try? await Task.sleep(nanoseconds: 500_000_000) // كل نص ثانية
            }
        }
    }

    func stop() {
        timerTask?.cancel()
    }
}
