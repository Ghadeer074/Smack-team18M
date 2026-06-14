//
//  CharacterCustomizationScreen.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 11/06/2026.
//
import SwiftUI

enum CustomizationCategory: String, CaseIterable {
    case headwear, eyes, mouth, color

    var icon: String {
        switch self {
        case .headwear: return "Icon_Headwear"
        case .eyes:     return "Icon_Eyes"
        case .mouth:    return "Icon_Mouth"
        case .color:    return "Icon_Color"
        }
    }
}

struct CharacterCustomizationScreen: View {

    @Environment(NavigationManager.self) private var nav

    @State private var playerName: String = ""
    @State private var selectedCategory: CustomizationCategory = .headwear
    @State private var selections: [CustomizationCategory: Int] = [
        .headwear: 0, .eyes: 0, .mouth: 0, .color: 0
    ]
    @State private var shake = false
    @State private var errorMessage = ""

    let optionCounts: [CustomizationCategory: Int] = [
        .headwear: 5, .eyes: 4, .mouth: 4, .color: 5
    ]

    var body: some View {
        ZStack {
            Color(.blue).ignoresSafeArea()

            GeometryReader { geo in
                VStack(spacing: geo.size.height * 0.025) {

                    // ======= title =======
                    TextTitle(
                        text: "صمم شخصيتك",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.11,
                        strokeWidth: 2,
                        color: Color(.yellow)
                    )
                    .rotationEffect(.degrees(-2))
                    .padding(.top, geo.size.height * 0.1)

                    // ======= category selector =======
                    ZStack {
                        ButtonView(
                            width: geo.size.width * 0.85,
                            height: geo.size.height * 0.13,
                            fillColor: .white,
                            borderColor: .black,
                            shadowWidth: 5
                        )
                        HStack(spacing: geo.size.width * 0.04) {
                            ForEach(CustomizationCategory.allCases, id: \.self) { category in
                                Button { selectedCategory = category } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.white))
                                            .frame(width: geo.size.width * 0.16, height: geo.size.width * 0.16)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        selectedCategory == category ? Color(.red) : Color(.black),
                                                        lineWidth: selectedCategory == category ? 4 : 3
                                                    )
                                            )
                                        Image(category.icon)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: geo.size.width * 0.1)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, geo.size.width * 0.1)

                    // ======= character preview =======
                    ZStack {
                        Image("CharacterBase_\(selections[.color] ?? 0)")
                            .resizable().scaledToFit().frame(width: geo.size.width * 0.55)
                        Image("Eyes_\(selections[.eyes] ?? 0)")
                            .resizable().scaledToFit().frame(width: geo.size.width * 0.55)
                        Image("Mouth_\(selections[.mouth] ?? 0)")
                            .resizable().scaledToFit().frame(width: geo.size.width * 0.55)
                        Image("Headwear_\(selections[.headwear] ?? 0)")
                            .resizable().scaledToFit().frame(width: geo.size.width * 0.55)

                        HStack {
                            Button { changeOption(by: -1) } label: {
                                ZStack {
                                    ButtonView(width: geo.size.width * 0.16, height: geo.size.width * 0.16,
                                               fillColor: Color(.red), borderColor: .black, shadowWidth: 4)
                                    Image(systemName: "play.fill")
                                        .foregroundStyle(.white)
                                        .font(.system(size: geo.size.width * 0.05))
                                        .rotationEffect(.degrees(180))
                                }
                            }
                            Spacer()
                            Button { changeOption(by: 1) } label: {
                                ZStack {
                                    ButtonView(width: geo.size.width * 0.16, height: geo.size.width * 0.16,
                                               fillColor: Color(.red), borderColor: .black, shadowWidth: 4)
                                    Image(systemName: "play.fill")
                                        .foregroundStyle(.white)
                                        .font(.system(size: geo.size.width * 0.05))
                                }
                            }
                        }
                        .frame(width: geo.size.width * 0.85)
                    }
                    .frame(height: geo.size.height * 0.25)

                    // ======= player name label =======
                    TextTitle(
                        text: "اسم اللاعب:",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.08,
                        strokeWidth: 0.5,
                        color: Color(.yellow)
                    )
                    .padding(.top, -geo.size.height * 0.01)

                    // ======= name text field =======
                    ZStack {
                        ButtonView(
                            width: geo.size.width * 0.7,
                            height: geo.size.height * 0.09,
                            fillColor: .white,
                            borderColor: errorMessage.isEmpty ? .black : Color(.red),
                            shadowWidth: 5
                        )
                        TextField(". . .", text: $playerName)
                            .font(.custom("Tajawal-Bold", size: geo.size.width * 0.08))
                            .foregroundStyle(Color(.black))
                            .multilineTextAlignment(.center)
                            .frame(width: geo.size.width * 0.6)
                            .onChange(of: playerName) {
                                if playerName.count > 10 {
                                    playerName = String(playerName.prefix(10))
                                    shake = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { shake = false }
                                }
                                if !playerName.isEmpty { errorMessage = "" }
                            }
                    }
                    .offset(x: shake ? 10 : 0)
                    .animation(.easeInOut(duration: 0.05).repeatCount(6, autoreverses: true), value: shake)

                    // ======= error message =======
                    Text(errorMessage)
                        .font(.custom("Tajawal-Black", size: geo.size.width * 0.045))
                        .foregroundStyle(Color(.red))
                        .padding(.horizontal, geo.size.width * 0.06)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white)
                                .opacity(errorMessage.isEmpty ? 0 : 1)
                        )
                        .opacity(errorMessage.isEmpty ? 0 : 1)
                        .animation(.easeInOut(duration: 0.2), value: errorMessage)
                        .frame(height: geo.size.height * 0.04)

                    Spacer()

                    // ======= next button =======
                    Button {
                        handleNext()
                        
                    } label: {
                        ZStack {
                            ButtonView(width: geo.size.width * 0.45, height: geo.size.height * 0.085, fillColor: Color(.red))
                            Text("التالي")
                                .font(.custom("Lalezar-Regular", size: geo.size.width * 0.085))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.bottom, geo.size.height * 0.1)

                }.frame(width: geo.size.width, height: geo.size.height)

                BackButton(geo: geo)
            }
        }
        .navigationBarHidden(true)

    }

    
    // ======= validation =======
    private func handleNext() {
        let trimmed = playerName.trimmingCharacters(in: .whitespaces)

        if trimmed.isEmpty {
            showError("اكتب اسمك أولاً !")
            return
        }

        nav.push(.waitingGameRoom)
        AudioManager.shared.playSound(SoundsList.popSound[0], fileExtension: SoundsList.popSound[1])
    }

    private func showError(_ message: String) {
        errorMessage = message
        shake = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { shake = false }
    }

    private func changeOption(by step: Int) {
        let count = optionCounts[selectedCategory] ?? 1
        var current = selections[selectedCategory] ?? 0
        current = (current + step + count) % count
        selections[selectedCategory] = current
    }
}

#Preview {
    CharacterCustomizationScreen()
        .environment(NavigationManager())
}
