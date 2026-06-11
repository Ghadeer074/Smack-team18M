//
//  RoundWinner.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 11/06/2026.
//
import SwiftUI

struct RoundWinner: View {
    
    @State private var move = false
    
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
                        color: .yellow
                    )
                    .rotationEffect(.degrees(-2))
                    .frame(width: geo.size.width * 0.9)
                    .multilineTextAlignment(.center)
                    .padding(.top, geo.size.height * 0.07)
                    .padding(.bottom, geo.size.height * 0.05)
                    
                    // ======= answer bubble =======
                    ZStack {
                        ButtonView(
                            width: geo.size.width * 0.85,
                            height: geo.size.height * 0.15,
                            fillColor: Color(.white),
                            borderColor: Color(.red),
                            shadowWidth: 7
                        )
                        Text("العيدية والنومة الطويلة بعد صلاة العيد مباشرة...")
                            .font(.custom("Tajawal-Black", size: geo.size.width * 0.055))
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                            .frame(width: geo.size.width * 0.7)
                    }
                    
                    // ======= character =======
                    Image("Character")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.7).border(.red)
                        .rotationEffect(.degrees(move ? -2 : 2))
                        .offset(y: move ? 4 : 7)
                        .animation(
                            .easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true),
                            value: move
                        )
                        .onAppear { move.toggle() }
                    
                    Spacer()
                    
                    // ======= player name =======
                    ZStack {
                        ButtonView(
                            width: geo.size.width * 0.4,
                            height: geo.size.height * 0.08,
                            fillColor: .white,
                            borderColor: .black,
                            shadowWidth: 4
                        )
                        Text("خالد")
                            .font(.custom("Tajawal-Black", size: geo.size.width * 0.075))
                            .foregroundStyle(Color(.red))
                            .offset(y: geo.size.height * 0.005)
                    }
                    .padding(.bottom, geo.size.height * 0.06)
                    
                }.frame(width: geo.size.width, height: geo.size.height)
                
            }
        }
    }
}

#Preview {
    RoundWinner()
}
