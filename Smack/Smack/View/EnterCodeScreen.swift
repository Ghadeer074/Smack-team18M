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

                    
                    // ======== انضم button ========
                    Button {
                        nav.push(.playerOrVoter)
                    } label: {
                        ZStack {
                            ButtonView(width: geo.size.width * 0.36, height: geo.size.height * 0.08, fillColor: Color(.red))
                            Text("انضم")
                                .font(.custom("Lalezar-Regular", size: geo.size.width * 0.08))
                                .foregroundStyle(.white)
                        }
                    }

                    Spacer().frame(height: geo.size.height * 0)

                }.frame(width: geo.size.width, height: geo.size.height)

                // ======== back button ========
                BackButton(geo: geo)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    EnterCodeScreen()
        .environment(NavigationManager())
}
