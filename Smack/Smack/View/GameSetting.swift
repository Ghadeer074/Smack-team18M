//
//  GameSetting.swift
//  Smack
//
//  Created by Nedaa on 09/06/2026.
//
import SwiftUI

struct GameSettingsView: View {
    @State private var selectedMode: String = "1v1"
    @State private var selectedCategories: Set<String> = ["عامة"]
    @State private var playerCount: Int = 2
    
    let modes = [
        ("1v1", "🤨"),
        ("فريق", "\u{1F6A9}")
    ]
    
    let categories = [
        ("تاريخ", "🗃️"),
        ("علوم", "✏️"),
        ("عامة", "🌍"),
        ("رياضة", "⚽"),
        ("دراما", "🖥️"),
        ("أفلام", "🎬")
    ]
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color(hex: "48A0B5")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    Text("إعدادات الجولة")
                        .font(.custom("Lalezar-Regular", size: 28))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.4), radius: 0, x: 3, y: 3)
                        .padding(.top, 20)
                    
                    VStack(alignment: .trailing, spacing: 12) {
                        Text("الطور:")
                            .font(.custom("Lalezar-Regular", size: 20))
                            .foregroundColor(Color(hex: "F7D13B"))
                            .shadow(color: .black.opacity(0.4), radius: 0, x: 2, y: 2)
                            .frame(maxWidth: .infinity, alignment: .trailing) //عني يمين
                            .padding(.trailing, 300)
                        HStack(spacing: 12) {
                            ForEach(modes, id: \.0) { mode in
                                Button(action: {
                                    selectedMode = mode.0
                                }) {
                                    VStack(spacing: 6) {
                                        Text(verbatim: mode.1)
                                            .font(.system(size: 28))
                                        Text(mode.0)
                                            .font(.custom("Lalezar-Regular", size: 16))
                                            .foregroundColor(.black)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 75)
                                    .background(selectedMode == mode.0 ? Color(hex: "F7D13B") : Color.white)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.black.opacity(0.15), lineWidth: 1.5)
                                    )
                                    .shadow(color: .black.opacity(0.25), radius: 0, x: 3, y: 3)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .trailing, spacing: 12) {
                        Text("الفئات:")
                            .font(.custom("Lalezar-Regular", size: 20))
                            .foregroundColor(Color(hex: "F7D13B"))
                            .shadow(color: .black.opacity(0.4), radius: 0, x: 2, y: 2)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 300)
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(categories, id: \.0) { cat in
                                Button(action: {
                                    if selectedCategories.contains(cat.0) {
                                        if selectedCategories.count > 1 {
                                            selectedCategories.remove(cat.0)
                                        }
                                    } else {
                                        selectedCategories.insert(cat.0)
                                    }
                                }) {
                                    VStack(spacing: 4) {
                                        Text(verbatim: cat.1)
                                            .font(.system(size: 26))
                                        Text(cat.0)
                                            .font(.custom("Lalezar-Regular", size: 14))
                                            .foregroundColor(.black)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 70)
                                    .background(selectedCategories.contains(cat.0) ? Color(hex: "F7D13B") : Color.white)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.black.opacity(0.15), lineWidth: 1.5)
                                    )
                                    .shadow(color: .black.opacity(0.25), radius: 0, x: 3, y: 3)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .trailing, spacing: 12) {
                        Text("عدد اللاعبين:")
                            .font(.custom("Lalezar-Regular", size: 20))
                            .foregroundColor(Color(hex: "F7D13B"))
                            .shadow(color: .black.opacity(0.4), radius: 0, x: 2, y: 2)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 260)

                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 150)
                    Button(action: {}) {
                        Text("انطلق!")
                            .font(.custom("Lalezar-Regular", size: 30))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 0, x: 2, y: 2)
                            .frame(maxWidth: .infinity)
                            .frame(height: 70)
                            .background(Color(hex: "BD272D"))
                            .cornerRadius(22)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(Color.black.opacity(0.3), lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.35), radius: 0, x: 4, y: 4)
                    }
                    .padding(.horizontal, 80)
                    .padding(.bottom, 110)
                }
            }
            

        }
        
        .environment(\.layoutDirection, .rightToLeft)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    GameSettingsView()
}
