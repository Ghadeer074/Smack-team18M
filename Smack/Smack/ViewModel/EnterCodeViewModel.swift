//
//  EnterCodeViewModel.swift
//  Smack
//

import Foundation

@MainActor
@Observable
class EnterCodeViewModel {
    var isLoading = false
    var errorMessage: String?
    var joinedSession: sessionModel?

    func joinSession(code: String) async {
        guard !code.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "أدخل الكود أولاً"
            return
        }
        isLoading = true
        errorMessage = nil
        joinedSession = nil

        do {
            guard let session = try await CloudKitManager.shared.fetchsession(byJoinCode: code.uppercased()) else {
                errorMessage = "الكود غلط، حاول مرة ثانية"
                isLoading = false
                return
            }

            // ── check session status ──
            if session.status == "ended" {
                errorMessage = "انتهت هذه اللعبة"
                isLoading = false
                return
            }

            if session.status == "playing" {
                errorMessage = "اللعبة بدأت، ما تقدر تنضم"
                isLoading = false
                return
            }

            // ── check if full ──
            let players = try await CloudKitManager.shared.fetchPlayers(forsession: session.id)
            if players.count >= session.maxPlayers {
                errorMessage = "الغرفة ممتلئة 🚫"
                isLoading = false
                return
            }

            joinedSession = session

        } catch {
            errorMessage = "مشكلة في الاتصال، تأكد من الإنترنت"
        }
        isLoading = false
    }
}
