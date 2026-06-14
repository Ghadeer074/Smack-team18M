//
//  GameSettingsScreen.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 11/06/2026.
//

import SwiftUI

enum GameMode {
    case team, oneVsOne
}

struct GameSettingsScreen: View {

    @Environment(NavigationManager.self) private var nav

    @State private var selectedMode: GameMode = .oneVsOne
    @State private var categories: [(emoji: String, name: String)] = [
        ("📜", "تاريخ"), ("🧪", "علوم"), ("🌍", "عامة"),
        ("📺", "دراما"), ("⚽️", "رياضة"), ("🎬", "أفلام")
    ]
    @State private var selectedCategory: String = "عامة"
    @State private var playerCount = 4
    @State private var roundCount = 3

    var body: some View {
        ZStack {
            Color(.blue).ignoresSafeArea()

            GeometryReader { geo in

                let headerHeight = geo.size.height * 0.1

                ZStack(alignment: .top) {

                    ScrollView {
                        VStack(spacing: geo.size.height * 0.025) {

                            Spacer()
                                .frame(height: headerHeight)

                            // ====== mode label =====
                            TextTitle(
                                text: "الطور:",
                                fontName: "Lalezar-Regular",
                                size: geo.size.width * 0.07,
                                strokeWidth: 1,
                                color: Color(.yellow)
                            )
                            .frame(width: geo.size.width * 0.85, alignment: .trailing)

                            // ===== mode selection =====
                            HStack(spacing: geo.size.width * 0.04) {

                                Button {
                                    selectedMode = .team
                                } label: {
                                    ZStack {
                                        ButtonView(
                                            width: geo.size.width * 0.42,
                                            height: geo.size.width * 0.27,
                                            fillColor: selectedMode == .team ? Color(.yellow) : .white,
                                            borderColor: selectedMode == .team ? Color(.red) : .black,
                                            shadowWidth: 5
                                        )

                                        VStack(spacing: 8) {
                                            Text("🎭")
                                                .font(.system(size: geo.size.width * 0.07))

                                            Text("فريق")
                                                .font(.custom("Tajawal-Black", size: geo.size.width * 0.05))
                                                .foregroundStyle(.black)
                                        }
                                    }
                                }

                                Button {
                                    selectedMode = .oneVsOne
                                } label: {
                                    ZStack {
                                        ButtonView(
                                            width: geo.size.width * 0.42,
                                            height: geo.size.width * 0.27,
                                            fillColor: selectedMode == .oneVsOne ? Color(.yellow) : .white,
                                            borderColor: selectedMode == .oneVsOne ? Color(.red) : .black,
                                            shadowWidth: 5
                                        )

                                        VStack(spacing: 8) {
                                            Text("⚔️")
                                                .font(.system(size: geo.size.width * 0.07))

                                            Text("1 VS 1")
                                                .font(.custom("Tajawal-Black", size: geo.size.width * 0.05))
                                                .foregroundStyle(.black)
                                        }
                                    }
                                }
                            }
                            .frame(width: geo.size.width * 0.85)

                            // ===== categories label =====
                            TextTitle(
                                text: "الفئات:",
                                fontName: "Lalezar-Regular",
                                size: geo.size.width * 0.07,
                                strokeWidth: 1,
                                color: Color(.yellow)
                            )
                            .frame(width: geo.size.width * 0.85, alignment: .trailing)
                            .padding(.top, geo.size.height * 0.01)

                            // ===== categories grid =====
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ],
                                spacing: geo.size.width * 0.05
                            ) {
                                ForEach(categories, id: \.name) { category in
                                    Button {
                                        selectedCategory = category.name
                                    } label: {
                                        ZStack {
                                            ButtonView(
                                                width: geo.size.width * 0.26,
                                                height: geo.size.width * 0.26,
                                                fillColor: selectedCategory == category.name ? Color(.yellow) : .white,
                                                borderColor: selectedCategory == category.name ? Color(.red) : .black,
                                                shadowWidth: 4
                                            )

                                            VStack(spacing: 6) {
                                                Text(category.emoji)
                                                    .font(.system(size: geo.size.width * 0.07))

                                                Text(category.name)
                                                    .font(.custom("Tajawal-Black", size: geo.size.width * 0.04))
                                                    .foregroundStyle(.black)
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(width: geo.size.width * 0.85)

                            // ===== player count =====
                            TextTitle(
                                text: "عدد اللاعبين:",
                                fontName: "Lalezar-Regular",
                                size: geo.size.width * 0.07,
                                strokeWidth: 1,
                                color: Color(.yellow)
                            )
                            .frame(width: geo.size.width * 0.85, alignment: .trailing)
                            .padding(.top, geo.size.height * 0.015)

                            StepperView(
                                value: $playerCount,
                                minValue: 4,
                                maxValue: 12,
                                geo: geo
                            )

                            // ===== round count =====
                            TextTitle(
                                text: "عدد الجولات:",
                                fontName: "Lalezar-Regular",
                                size: geo.size.width * 0.07,
                                strokeWidth: 1,
                                color: Color(.yellow)
                            )
                            .frame(width: geo.size.width * 0.85, alignment: .trailing)
                            .padding(.top, geo.size.height * 0.015)

                            StepperView(
                                value: $roundCount,
                                minValue: 3,
                                maxValue: 10,
                                geo: geo
                            )

                            Spacer()
                                .frame(height: geo.size.height * 0.05)

                            // ===== انطلق button =====
                            Button {
                                nav.push(.characterCustomization)
                                AudioManager.shared.playSound(SoundsList.popSound[0], fileExtension: SoundsList.popSound[1])
                            } label: {
                                ZStack {
                                    ButtonView(
                                        width: geo.size.width * 0.5,
                                        height: geo.size.height * 0.085,
                                        fillColor: Color(.red),
                                        borderColor: .black
                                    )

                                    Text("انطلق")
                                        .font(.custom("Lalezar-Regular", size: geo.size.width * 0.08))
                                        .foregroundStyle(.white)
                                }
                            }

                            Spacer()
                                .frame(height: geo.size.height * 0.04)
                        }
                        .frame(width: geo.size.width)
                    }

                    // ===== fixed header =====
                    VStack(spacing: 0) {

                        HStack {

                            BackButton(geo: geo)

                            Spacer()

                            TextTitle(
                                text: "إعدادات الجولة",
                                fontName: "Lalezar-Regular",
                                size: geo.size.width * 0.1,
                                strokeWidth: 2
                            )

                            Spacer()

                            Color.clear
                                .frame(
                                    width: geo.size.width * 0.12,
                                    height: geo.size.width * 0.12
                                )
                        }
                        .padding(.top, geo.size.height * 0.02)

                        Spacer()

                        
                    }
                    .frame(height: headerHeight)
                    .background(Color(.blue))
                    .zIndex(100)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    GameSettingsScreen()
        .environment(NavigationManager())
}

// ======= reusable stepper helper =======

struct StepperView: View {
    @Binding var value: Int
    var minValue: Int = 0
    var maxValue: Int = 99
    var geo: GeometryProxy
    
    var body: some View {
        HStack(spacing: geo.size.width * 0.04) {
            
            Button {
                if value > minValue { value -= 1 }
            } label: {
                ZStack {
                    ButtonView(
                        width: geo.size.width * 0.2,
                        height: geo.size.height * 0.07,
                        fillColor: Color(.red),
                        borderColor: .black,
                        shadowWidth: 4
                    )
                    Image(systemName: "play.fill")
                        .foregroundStyle(.white)
                        .font(.system(size: geo.size.width * 0.05))
                        .rotationEffect(.degrees(180))
                }
            }
            
            ZStack {
                ButtonView(
                    width: geo.size.width * 0.2,
                    height: geo.size.height * 0.07,
                    fillColor: .white,
                    borderColor: .black,
                    shadowWidth: 0
                )
                Text("\(value)")
                    .font(.custom("Tajawal-Black", size: geo.size.width * 0.06))
                    .foregroundStyle(.black)
                    .offset(y: geo.size.height * 0.005)
            }
            
            
            Button {
                if value < maxValue { value += 1 }
            } label: {
                ZStack {
                    ButtonView(
                        width: geo.size.width * 0.2,
                        height: geo.size.height * 0.07,
                        fillColor: Color(.red),
                        borderColor: .black,
                        shadowWidth: 4
                    )
                    Image(systemName: "play.fill")
                        .foregroundStyle(.white)
                        .font(.system(size: geo.size.width * 0.05))
                }
            }
            
        }
        .frame(width: geo.size.width * 0.85)
    }
}

