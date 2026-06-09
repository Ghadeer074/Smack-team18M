//
//  VotingScreen.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 04/06/2026.
//
import SwiftUI

struct VotingScreen: View {
    @State private var move = false
    @State private var bounce1 = false
    @State private var bounce2 = false
    
    var body: some View {
        ZStack {
            
            Color(.blue).ignoresSafeArea()
            
            GeometryReader { geo in
                Image("TinyCharacter")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.7)
                    .rotationEffect(.degrees(-140))
                    .position(x: geo.size.width * 0.9, y: geo.size.height * -0.03)
                    .offset(y: move ? -8 : 1)
                    .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true), value: move)
                    .onAppear { move.toggle() }
                
                VStack {
                    
                    TextTitle(
                        text: "الإجابة الشاطحة...؟",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.12,
                        strokeWidth: 1,
                        color: Color(.yellow)
                    )
                    .rotationEffect(.degrees(-2))
                    
                    // ======= button 1 =======
                    Button {
                        
                    } label: {
                        ZStack {
                            ButtonView(width: geo.size.width * 0.75, height: geo.size.height * 0.2)
                            Text("Answer")
                                .font(.custom("Tajawal-Black", size: geo.size.width * 0.06))
                                .foregroundStyle(.black)
                        }
                    }
                    .rotationEffect(.degrees(-3))
                    .offset(x: bounce1 ? 3 : -3, y: bounce1 ? -5 : 0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: bounce1)
                    
                    // ======= VS image =======
                    Image("VS")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.6, height: geo.size.height * 0.25)
                    
                    // ======= button 2 =======
                    Button {
                        
                    } label: {
                        ZStack {
                            ButtonView(width: geo.size.width * 0.75, height: geo.size.height * 0.2)
                            Text("Answer")
                                .font(.custom("Tajawal-Black", size: geo.size.width * 0.06))
                                .foregroundStyle(.black)
                        }
                    }
                    .rotationEffect(.degrees(3))
                    .offset(x: bounce2 ? -3 : 3, y: bounce2 ? -5 : 0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: bounce2)
                    
                }.frame(width: geo.size.width, height: geo.size.height)
                
            }
        }
        .onAppear {
            bounce1 = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                bounce2 = true
            }
        }
    }
}

#Preview {
    VotingScreen()
}
