//
//  VotingScreen.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 04/06/2026.
//
import SwiftUI

struct VotingScreen: View {
    @State private var move = false
    
    var body: some View {
        ZStack {
            
            Color(.blue).ignoresSafeArea()
            
            GeometryReader { geo in
                Image("TinyCharacter")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.7)
                    .rotationEffect(.degrees(-140))
                    .position(
                        x: geo.size.width * 0.9,
                        y: geo.size.height * -0.03
                    )
                    .offset(
                        y: move ? -8 : 1
                    )
                
                    .animation(.easeInOut(duration: 1.3)
                        .repeatForever(autoreverses: true),
                               value: move
                    )
                
                    .onAppear {
                        move.toggle()
                    }
                
                VStack {
                    TextTitle(text: "الإجابة الشاطحة...؟", fontName: "Lalezar-Regular", size: geo.size.width * 0.12, strokeWidth: 1, color: Color(.yellow))
                        .rotationEffect(.degrees(-2))
                    
                    Button {
                        
                    } label: {
                        
                        ZStack {
                            
                            ButtonView(width: geo.size.width * 0.75, height: geo.size.height * 0.2)
                            Text("Answer").font(.custom("Tajawal-Black", size: geo.size.width * 0.06))
                                .foregroundStyle(Color(.black))
                        }
                        
                    }.rotationEffect(.degrees(-3))
                    
                    Image("VS")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.6, height: geo.size.height * 0.25)
                    
                    Button {
                        
                    } label: {
                        
                        ZStack {
                            
                            ButtonView(width: geo.size.width * 0.75, height: geo.size.height * 0.2)
                            Text("Answer").font(.custom("Tajawal-Black", size: geo.size.width * 0.06))
                                .foregroundStyle(Color(.black))
                        }
                        
                    }.rotationEffect(.degrees(3))
                    
                    
                    
                }.frame(width: geo.size.width, height: geo.size.height)
                
            }
            
            
            
        }
        
    }
}

#Preview {
    VotingScreen()
}
