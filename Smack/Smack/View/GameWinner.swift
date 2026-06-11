//
//  GameWinner.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 11/06/2026.
//

import SwiftUI

struct GameWinner: View {
    
    @State private var move = false
    
    @State private var titleVisible = false
    @State private var characterVisible = false
    @State private var nameVisible = false
    
    var body: some View {
        ZStack {
            Color(.blue).ignoresSafeArea()
            
            GeometryReader { geo in
                VStack(spacing: geo.size.height * 0.05) {
                    
                    // ======= title =======
                    TextTitle(
                        text: "الشاطح في اللعبة",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.15,
                        strokeWidth: 1,
                        color: Color(.yellow)
                    )
                    .frame(width: geo.size.width * 0.9)
                    .multilineTextAlignment(.center)
                    .rotationEffect(.degrees(-2))
                    .padding(.top, geo.size.height * 0.07)
                    .scaleEffect(titleVisible ? 1 : 0)
                    .animation(.spring(duration: 0.5), value: titleVisible)

                    
                    Spacer()
                    
                    // ======= character =======
                    Image("Character")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.55)
                        .rotationEffect(.degrees(move ? 4 : -4))
                        .offset(y: move ? -8 : 0)
                        .animation(
                            .easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true),
                            value: move
                        )
                        .opacity(characterVisible ? 1 : 0)
                        .scaleEffect(characterVisible ? 1 : 0.6)
                        .animation(.spring(duration: 0.5), value: characterVisible)
                    
                    // ======= player name =======
                    TextTitle(
                        text: "نوف",
                        fontName: "Tajawal-Black",
                        size: geo.size.width * 0.22,
                        strokeWidth: 3,
                        color: Color(.red)
                    )
                    .opacity(nameVisible ? 1 : 0)
                    .scaleEffect(nameVisible ? 1 : 0.5)
                    .animation(.spring(duration: 0.5), value: nameVisible)
                    
                    Spacer()
                    
                }.frame(width: geo.size.width, height: geo.size.height)
                
            }
        }
        .onAppear {
            
            // step 1 — title pops in
            titleVisible = true
            
            // step 2 — character pops in + starts swaying
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                characterVisible = true
                move.toggle()
            }
            
            // step 3 — name pops in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                nameVisible = true
            }
            
        }
    }
}

#Preview {
    GameWinner()
}
