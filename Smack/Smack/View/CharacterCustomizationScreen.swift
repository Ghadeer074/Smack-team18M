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
        case .eyes: return "Icon_Eyes"
        case .mouth: return "Icon_Mouth"
        case .color: return "Icon_Color"
        }
    }
}

struct CharacterCustomizationScreen: View {
    
    @State private var playerName: String = ""
    @State private var selectedCategory: CustomizationCategory = .headwear
    
    // index of selected option for each category
    @State private var selections: [CustomizationCategory: Int] = [
        .headwear: 0,
        .eyes: 0,
        .mouth: 0,
        .color: 0
    ]
    
    // number of options available per category
    let optionCounts: [CustomizationCategory: Int] = [
        .headwear: 5,
        .eyes: 4,
        .mouth: 4,
        .color: 5
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
                    .padding(.top, geo.size.height * 0.02)
                    
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
                                Button {
                                    selectedCategory = category
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
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
                                            .scaledToFit()
                                            .frame(width: geo.size.width * 0.1)
                                    }
                                }
                            }
                        }
                    }
                    
                    // ======= character preview =======
                    ZStack {
                        
                        // base body — color changes based on selection
                        Image("CharacterBase_\(selections[.color] ?? 0)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.55)
                            .border(.blue)
                        
                        // eyes layer
                        Image("Eyes_\(selections[.eyes] ?? 0)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.55)
                        
                        // mouth layer
                        Image("Mouth_\(selections[.mouth] ?? 0)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.55)
                        
                        // headwear layer
                        Image("Headwear_\(selections[.headwear] ?? 0)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.55).border(.red)
                        
                    }
                    .frame(height: geo.size.height * 0.25)
                    
                    // ======= left/right arrows for current category =======
                    HStack {
                        
                        // previous option
                        Button {
                            changeOption(by: -1)
                        } label: {
                            ZStack {
                                ButtonView(
                                    width: geo.size.width * 0.16,
                                    height: geo.size.width * 0.16,
                                    fillColor: Color(.red),
                                    borderColor: Color(.black),
                                    shadowWidth: 4
                                )
                                Image(systemName: "play.fill")
                                    .foregroundStyle(.white)
                                    .font(.system(size: geo.size.width * 0.05))
                                    .rotationEffect(.degrees(180))
                            }
                        }
                        
                        Spacer()
                        
                        // next option
                        Button {
                            changeOption(by: 1)
                        } label: {
                            ZStack {
                                ButtonView(
                                    width: geo.size.width * 0.16,
                                    height: geo.size.width * 0.16,
                                    fillColor: Color(.red),
                                    borderColor: Color(.black),
                                    shadowWidth: 4
                                )
                                Image(systemName: "play.fill")
                                    .foregroundStyle(.white)
                                    .font(.system(size: geo.size.width * 0.05))
                            }
                        }
                        
                    }
                    .frame(width: geo.size.width * 0.85)
                    .offset(y: -geo.size.height * 0.16) // bring arrows beside the character
                    
                    // ======= player name label =======
                    TextTitle(
                        text: "اسم اللاعب:",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.08,
                        strokeWidth: 0.5,
                        color: Color(.yellow)
                    )
                    
                    // ======= name text field =======
                    ZStack {
                        ButtonView(
                            width: geo.size.width * 0.7,
                            height: geo.size.height * 0.09,
                            fillColor: .white,
                            borderColor: .black,
                            shadowWidth: 5
                        )
                        
                        TextField(". . .", text: $playerName)
                            .font(.custom("Tajawal-Bold", size: geo.size.width * 0.08))
                            .multilineTextAlignment(.center)
                            .frame(width: geo.size.width * 0.75)
                    }
                    
                    Spacer()
                    
                    // ======= next button =======
                    Button {
                        
                        
                    } label: {
                        ZStack {
                            ButtonView(width: geo.size.width * 0.45, height: geo.size.height * 0.085, fillColor: Color(.red))
                            
                            Text("التالي").font(.custom("Lalezar-Regular", size: geo.size.width * 0.085)).foregroundStyle(.white)
                        }
                    }
                    .padding(.bottom, geo.size.height * 0.03)
                    
                }.frame(width: geo.size.width, height: geo.size.height)
                
            }
        }
    }
    
    // ======= cycle through options for the selected category =======
    private func changeOption(by step: Int) {
        let count = optionCounts[selectedCategory] ?? 1
        var current = selections[selectedCategory] ?? 0
        current = (current + step + count) % count
        selections[selectedCategory] = current
    }
}

#Preview {
    CharacterCustomizationScreen()
}
