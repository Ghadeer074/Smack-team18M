//
//  WaitingGameRoomViewModel.swift
//  Smack
//

import Foundation
import CloudKit

@MainActor
@Observable
class WaitingGameRoomViewModel {

    var players: [PlayerModel] = []
    var isLoading = false
    var errorMessage: String?
    var gameStarted = false
    var firstQuestion: sessionQuestionModel?
    var cachedTotalRounds: Int = 1

    private var pollingTask: Task<Void, Never>?
    private var currentJoinCode: String = ""

    func startPolling(session: sessionModel) {
        currentJoinCode = session.joinCode
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                await fetchPlayers(sessionID: session.id)
                await checkSessionStarted(sessionID: session.id)
                try? await Task.sleep(nanoseconds: 3_000_000_000)
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    private func fetchPlayers(sessionID: UUID) async {
        do {
            players = try await CloudKitManager.shared.fetchPlayers(forsession: sessionID)
        } catch {
            errorMessage = "تعذر تحميل اللاعبين"
        }
    }

    private func checkSessionStarted(sessionID: UUID) async {
        guard !currentJoinCode.isEmpty && !gameStarted else { return }
        do {
            if let session = try await CloudKitManager.shared.fetchsession(byJoinCode: currentJoinCode),
               session.status == "playing" {
                // ── جيب الـ SessionQuestions بفلتر بسيط على session_id فقط ──
                let predicate = NSPredicate(format: "session_id == %@", sessionID.uuidString)
                let questions: [sessionQuestionModel] = try await CloudKitManager.shared.fetch(
                    recordType: "SessionQuestion",
                    predicate: predicate
                )
                firstQuestion = questions.first
                cachedTotalRounds = session.roundCount
                gameStarted = true
                pollingTask?.cancel()
            }
        } catch {}
    }

    func startGame(session: sessionModel) async {
        isLoading = true
        errorMessage = nil
        do {
            // ── جيب كل الأسئلة بدون فلتر ──
            let allQuestions: [QuestionModel] = try await CloudKitManager.shared.fetch(
                recordType: "Question",
                predicate: NSPredicate(value: true)
            )

            guard let randomQuestion = allQuestions.randomElement() else {
                errorMessage = "ما فيه أسئلة في قاعدة البيانات"
                isLoading = false
                return
            }

            // ── أنشئ SessionQuestion ──
            let container = CKContainer(identifier: "iCloud.com.Smack")
            let record = CKRecord(recordType: "SessionQuestion")
            record["id"] = UUID().uuidString as CKRecordValue
            record["session_id"] = session.id.uuidString as CKRecordValue
            record["question_id"] = randomQuestion.id.uuidString as CKRecordValue
            record["round_number"] = 1 as CKRecordValue
            record["was_answerd"] = 0 as CKRecordValue
            record["total_rounds"] = session.roundCount as CKRecordValue

            let savedRecord = try await container.publicCloudDatabase.save(record)
            firstQuestion = sessionQuestionModel(from: savedRecord)

            // ── غيّر status الـ session ──
            try await CloudKitManager.shared.updatesessionStatus(
                sessionID: session.id,
                status: "playing"
            )

            gameStarted = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
