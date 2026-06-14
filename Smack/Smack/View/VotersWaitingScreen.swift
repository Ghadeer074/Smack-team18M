//
//  VotersWaitingScreen.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 09/06/2026.
//
import SwiftUI

struct VotersWaitingScreen: View {
    
    @State private var move = false
    
    var body: some View {
        
        ZStack {
            Color(.blue).ignoresSafeArea()
            
            
            GeometryReader { geo in
                
                VStack {
                    
                    TextTitle(text: "ننتظر اللاعبين !", fontName: "Lalezar-Regular", size: geo.size.width * 0.13, strokeWidth: 2, color: Color(.white)).padding()
                    
                    ZStack {
                        ButtonView(width: geo.size.width * 0.85, height: geo.size.height * 0.22)
                        
                        Text("Question")
                    }
                    Image("SplashScreen_Character")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.7)
                        .rotationEffect(.degrees(0))
                        .rotationEffect(.degrees(move ? 2 : 10))
                    
                        .animation(.spring(duration: 1.8)
                            .repeatForever(autoreverses: true),
                                   value: move
                        )
                    
                        .onAppear {
                            move.toggle()
                        }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.yellow, lineWidth: 4)
                            )
                            .frame(width: geo.size.width * 0.85, height: geo.size.height * 0.15)
                        
                        VStack(spacing: 8) {
                            Text("اللاعبين الذين انتهوا:")
                                .font(.custom("Tajawal-Bold", size: geo.size.width * 0.05))
                                .foregroundStyle(.white)
                            
                            TextTitle(
                                text: "1 / 2",
                                fontName: "Lalezar-Regular",
                                size: geo.size.width * 0.1,
                                strokeWidth: 0,
                                color: .yellow
                            )
                        }
                    }
                    
                    Spacer()
                    
                    
                    
                    
                }.frame(width: geo.size.width, height: geo.size.height)
                
                
            } // end of GeometryReader
            
            
            
        } // end of ZStack
        
    }
}

#Preview {
    VotersWaitingScreen()
}
