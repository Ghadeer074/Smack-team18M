//
//  EnterCodeScreen.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 27/05/2026.
//
import SwiftUI

struct EnterCodeScreen: View {

    @Environment(NavigationManager.self) private var nav
    @State private var code = ""
    @State private var shake = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            Color(.blue).ignoresSafeArea()

            GeometryReader { geo in
                VStack(spacing: geo.size.height * 0.05) {

                    TextTitle(
                        text: "ادخل رقم الغرفة",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.11,
                        strokeWidth: 2,
                        color: Color(.yellow)
                    )

                    // ======== text field ========
                    ZStack {
                        ButtonView(width: geo.size.width * 0.8, height: 95)
                        TextField(". . .", text: $code)
                            .font(.custom("Lalezar-Regular", size: geo.size.width * 0.1))
                            .foregroundStyle(Color(.black))
                            .multilineTextAlignment(.center)
                            .keyboardType(.asciiCapableNumberPad)
                            .padding(.horizontal)
                            .onChange(of: code) {
                                // clear error as soon as they start typing
                                if !code.isEmpty { errorMessage = "" }

                                if code.count > 6 {
                                    code = String(code.prefix(6))
                                    shake = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { shake = false }
                                }
                            }
                    }
                    .offset(x: shake ? 10 : 0)
                    .animation(.easeInOut(duration: 0.05).repeatCount(6, autoreverses: true), value: shake)
                    
                    Text("اسأل المضيف عن رقم الغرفة!")
                        .font(.custom("Tajawal-Black", size: geo.size.width * 0.04))
                        .foregroundStyle(.white)
                        .opacity(0.6)

                    // ======== error message ========
                    Text(errorMessage)
                        .font(.custom("Tajawal-Black", size: geo.size.width * 0.045))
                        .foregroundStyle(Color(.red))
                        .padding(.horizontal, geo.size.width * 0.08)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white)
                                .opacity(errorMessage.isEmpty ? 0 : 1)
                        )
                        .opacity(errorMessage.isEmpty ? 0 : 1)
                        .animation(.easeInOut(duration: 0.2), value: errorMessage)
                        .offset(y: -geo.size.height * 0.02)

                    
                    // ======== انضم button ========
                    Button {
                        handleJoin()
                        
                    } label: {
                        ZStack {
                            ButtonView(width: geo.size.width * 0.36, height: geo.size.height * 0.08, fillColor: Color(.red))
                            Text("انضم")
                                .font(.custom("Lalezar-Regular", size: geo.size.width * 0.08))
                                .foregroundStyle(.white)
                        }
                    }
                    .offset(y: -geo.size.height * 0.02)

                }.frame(width: geo.size.width, height: geo.size.height)

                // ======== back button ========
                BackButton(geo: geo)
            }
        }
        .navigationBarHidden(true)
    }

    // ======== validation ========
    private func handleJoin() {
        if code.isEmpty {
            showError("أدخل رقم الغرفة أولاً !")
            return
        }

        if code.count < 4 {
            showError("الرقم قصير جداً !")
            return
        }

        // TODO: replace this with your real room-exists check
        let validCodes = ["123456", "B8G7"]
        if !validCodes.contains(code.uppercased()) {
            showError("الغرفة غير موجودة !")
            return
        }

        // all good —> navigate
        errorMessage = ""
        nav.push(.playerOrVoter)
        AudioManager.shared.playSound(SoundsList.popSound[0], fileExtension: SoundsList.popSound[1])
    }

    private func showError(_ message: String) {
        errorMessage = message
        shake = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { shake = false }
    }
}

#Preview {
    EnterCodeScreen()
        .environment(NavigationManager())
}
