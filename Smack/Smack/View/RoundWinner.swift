//
//  RoundWinner.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 11/06/2026.
//
import SwiftUI

struct RoundWinner: View {
    
    @State private var move = false
    
    @State private var titleVisible = false
    @State private var bubbleVisible = false
    @State private var characterVisible = false
    @State private var nameVisible = false
    
    var body: some View {
        ZStack {
            Color(.blue).ignoresSafeArea()
            
            GeometryReader { geo in
                VStack(spacing: geo.size.height * 0.04) {
                    
                    // ======= title =======
                    TextTitle(
                        text: "أطلق شطحة في الجولة!",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.1,
                        strokeWidth: 2,
                        color: Color(.yellow)
                    )
                    .frame(width: geo.size.width * 0.9)
                    .multilineTextAlignment(.center)
                    .rotationEffect(.degrees(-2))
                    .padding(.top, geo.size.height * 0.08)
                    .padding(.bottom, geo.size.height * 0.03)
                    .scaleEffect(titleVisible ? 1 : 0)
                    .animation(.spring(duration: 0.5), value: titleVisible)
                    
                    // ======= answer bubble =======
                    ZStack {
                        ButtonView(
                            width: geo.size.width * 0.85,
                            height: geo.size.height * 0.15,
                            fillColor: Color(.white),
                            borderColor: Color(.red),
                            shadowWidth: 6
                        )
                        Text("العيدية والنومة الطويلة بعد صلاة العيد مباشرة...")
                            .font(.custom("Tajawal-Black", size: geo.size.width * 0.055))
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                            .frame(width: geo.size.width * 0.7)
                    }
                    .opacity(bubbleVisible ? 1 : 0)
                    .offset(y: bubbleVisible ? 0 : -geo.size.height * 0.05)
                    .animation(.easeOut(duration: 0.5), value: bubbleVisible)
                    .padding(.bottom, geo.size.height * 0.05)
                    
                    // ======= character =======
                    Image("Character")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.7)
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
                    
                    Spacer()
                    
                    // ======= player name =======
                    ZStack {
                        ButtonView(
                            width: geo.size.width * 0.45,
                            height: geo.size.height * 0.085,
                            fillColor: Color(.red),
                            borderColor: .black,
                            shadowWidth: 5
                        )
                        Text("خالد")
                            .font(.custom("Tajawal-Black", size: geo.size.width * 0.08))
                            .foregroundStyle(Color(.white))
                            .offset(y: geo.size.height * 0.005)
                        
                    }
                    .padding(.bottom, geo.size.height * 0.08)
                    .opacity(nameVisible ? 1 : 0)
                    .offset(y: nameVisible ? 0 : geo.size.height * 0.05)
                    .animation(.easeOut(duration: 0.5), value: nameVisible)
                    
                }.frame(width: geo.size.width, height: geo.size.height)
                
            }
        }
        .onAppear {
            
            // step 1: title pops in
            titleVisible = true
            
            // step 2: bubble fades + slides down
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                bubbleVisible = true
            }
            
            // step 3: character pops in + starts swaying
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                characterVisible = true
                move.toggle()
            }
            
            // step 4: name slides up
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                nameVisible = true
            }
            
        }
    }
}

#Preview {
    RoundWinner()
}
