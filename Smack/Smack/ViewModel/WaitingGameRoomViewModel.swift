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

    private var currentSession: sessionModel?
    private var pollingTask: Task<Void, Never>?

    func startPolling(session: sessionModel) {
        self.currentSession = session
        pollingTask?.cancel()
        // ── fetch immediately on start ──
        Task { await fetchPlayers(sessionID: session.id) }
        pollingTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                async let p: () = fetchPlayers(sessionID: session.id)
                async let c: () = checkSessionStarted(sessionID: session.id)
                _ = await (p, c)
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    func fetchPlayers(sessionID: UUID) async {
        do {
            players = try await CloudKitManager.shared.fetchPlayers(forsession: sessionID)
        } catch {
            errorMessage = "تعذر تحميل اللاعبين"
        }
    }

    private func checkSessionStarted(sessionID: UUID) async {
        guard let joinCode = currentSession?.joinCode, !gameStarted else { return }
        do {
            if let session = try await CloudKitManager.shared.fetchsession(byJoinCode: joinCode),
               session.status == "playing" {
                let predicate = NSPredicate(format: "session_id == %@", sessionID.uuidString)
                let questions: [sessionQuestionModel] = try await CloudKitManager.shared.fetch(
                    recordType: "SessionQuestion", predicate: predicate
                )
                firstQuestion = questions.first
                cachedTotalRounds = session.roundCount
                gameStarted = true
                pollingTask?.cancel()
            }
        } catch {}
    }

    func startGame(session: sessionModel, totalRounds: Int) async {
        isLoading = true
        errorMessage = nil

        let rounds = UserDefaults.standard.integer(forKey: "smack.totalRounds")
        let finalRounds = rounds > 0 ? rounds : totalRounds

        do {
            let allQuestions: [QuestionModel] = try await CloudKitManager.shared.fetch(
                recordType: "Question", predicate: NSPredicate(value: true)
            )
            guard let randomQuestion = allQuestions.randomElement() else {
                errorMessage = "ما فيه أسئلة في قاعدة البيانات"
                isLoading = false
                return
            }

            let container = CKContainer(identifier: "iCloud.com.Smack")
            let record = CKRecord(recordType: "SessionQuestion")
            record["id"] = UUID().uuidString as CKRecordValue
            record["session_id"] = session.id.uuidString as CKRecordValue
            record["question_id"] = randomQuestion.id.uuidString as CKRecordValue
            record["round_number"] = 1 as CKRecordValue
            record["was_answerd"] = 0 as CKRecordValue
            record["total_rounds"] = finalRounds as CKRecordValue

            let savedRecord = try await container.publicCloudDatabase.save(record)
            firstQuestion = sessionQuestionModel(from: savedRecord)
            cachedTotalRounds = finalRounds

            try await CloudKitManager.shared.updatesessionStatus(
                sessionID: session.id, status: "playing"
            )
            gameStarted = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
