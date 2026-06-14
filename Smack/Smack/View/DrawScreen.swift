//
//  DrawScreen.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 11/06/2026.
//

import SwiftUI

struct DrawScreen: View {
    
    @State private var char1Visible = false
    @State private var char2Visible = false
    @State private var titleVisible = false
    @State private var arranged = false
    @State private var judgeVisible = false
    @State private var bubbleVisible = false
    
    @State private var move1 = false
    @State private var move2 = false
    @State private var moveJudge = false
    
    var body: some View {
        ZStack {
            Color(.blue).ignoresSafeArea()
            
            GeometryReader { geo in
                
                ZStack {
                    
                    TextTitle(
                        text: "تــعــادل !",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.24,
                        strokeWidth: 1,
                        color: Color(.red)
                    )
                    .rotationEffect(arranged ? .degrees(-3) : .degrees(0))
                    .scaleEffect(titleVisible ? 1 : 0)
                    .animation(.spring(duration: 0.5), value: titleVisible)
                    .position(
                        x: geo.size.width * 0.5,
                        y: arranged ? geo.size.height * 0.15 : geo.size.height * 0.45
                    )
                    .animation(.easeInOut(duration: 0.8), value: arranged)
                    
                    // ======= character 1 =======
                    ZStack {
                        Image("Character")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.4)
                            .rotationEffect(.degrees(move1 ? 4 : -4))
                            .offset(y: move1 ? -8 : 0)
                            .animation(
                                .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                                value: move1
                            )
                    }
                    .scaleEffect(arranged ? 1 : 1.5)
                    .opacity(char1Visible ? 1 : 0)
                    .position(
                        x: arranged ? geo.size.width * 0.28 : geo.size.width * 0.5,
                        y: char1Visible
                            ? (arranged ? geo.size.height * 0.33 : geo.size.height * 0.2)
                            : -geo.size.height * 0.2
                    )
                    .animation(.easeOut(duration: 0.6), value: char1Visible)
                    .animation(.easeInOut(duration: 0.8), value: arranged)
                    
                    // ======= character 2 =======
                    ZStack {
                        Image("Character")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.4)
                            .rotationEffect(.degrees(move2 ? -4 : 4))
                            .offset(y: move2 ? -8 : 0)
                            .animation(
                                .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                                value: move2
                            )
                    }
                    .scaleEffect(arranged ? 1 : 1.5)
                    .opacity(char2Visible ? 1 : 0)
                    .position(
                        x: arranged ? geo.size.width * 0.73 : geo.size.width * 0.5,
                        y: char2Visible
                        ? (arranged ? geo.size.height * 0.34 : geo.size.height * 0.75)
                            : geo.size.height * 1.2
                    )
                    .animation(.easeOut(duration: 0.6), value: char2Visible)
                    .animation(.easeInOut(duration: 0.8), value: arranged)
                    
                    // ================================
                    
                    ZStack {
                        ButtonView(
                            width: geo.size.width * 0.85,
                            height: geo.size.height * 0.13,
                            fillColor: .white,
                            borderColor: Color(.red),
                            shadowWidth: 6
                        )
                        Text("نحتاج جولة إضافية مع التعادل!")
                            .font(.custom("Tajawal-Black", size: geo.size.width * 0.05))
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                            .frame(width: geo.size.width * 0.75)
                    }
                    .opacity(bubbleVisible ? 1 : 0)
                    .scaleEffect(bubbleVisible ? 1 : 0.5)
                    .animation(.spring(duration: 0.5), value: bubbleVisible)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.55)
                    
                    
                    ZStack {
                        Image("SplashScreen_Character")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.6)
                            .rotationEffect(.degrees(moveJudge ? 3 : -3))
                            .offset(y: moveJudge ? -6 : 0)
                            .animation(
                                .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                                value: moveJudge
                            )
                    }
                    .opacity(judgeVisible ? 1 : 0)
                    .position(
                        x: geo.size.width * 0.5,
                        y: judgeVisible
                            ? geo.size.height * 0.8
                            : geo.size.height * 1.2
                    )
                    .animation(.easeOut(duration: 0.6), value: judgeVisible)
                    
                }
                .frame(width: geo.size.width, height: geo.size.height)
                
            }
        }
        .onAppear {
            
            // step 1: char1 slides down from top
            char1Visible = true
            
            // step 2: char2 slides up from bottom
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                char2Visible = true
            }
            
            // step 3: title pops in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                titleVisible = true
            }
            
            // step 4: rearrange to final layout
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                arranged = true
            }
            
            // step 5: start sway for char1 & char2 AFTER they settle
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                move1.toggle()
                move2.toggle()
            }
            
            // step 6: judge character slides up
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                judgeVisible = true
            }
            
            // start judge sway AFTER it settles
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                moveJudge.toggle()
            }
            
            // step 7: speech bubble appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                bubbleVisible = true
            }
            
        }
    }
}

#Preview {
    DrawScreen()
}
