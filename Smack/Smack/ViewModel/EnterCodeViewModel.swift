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
        do {
            if let session = try await CloudKitManager.shared.fetchsession(byJoinCode: code.uppercased()) {
                joinedSession = session
            } else {
                errorMessage = "الكود غلط، حاول مرة ثانية"
            }
        } catch {
            errorMessage = "مشكلة في الاتصال، تأكد من الإنترنت"
        }
        isLoading = false
    }
}
