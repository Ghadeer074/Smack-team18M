//
//  SplashScreen.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 30/05/2026.
//

import SwiftUI

struct SplashScreen: View {
    
    // step 1
    @State private var bubble1Visible = false
    // step 2
    @State private var characterVisible = false
    // step 3
    @State private var bubble2Visible = false
    // step 5
    @State private var characterTilted = false
    // step 6
    @State private var titleVisible = false
    // step 7
    @State private var starsVisible = false
    // step 8
    @State private var buttonVisible = false
    
    var body: some View {
        
        ZStack {
            Color(.blue).ignoresSafeArea()
            
            GeometryReader { geo in
                
                ZStack {
                    
                    // ======= step 1 — talk bubble 1 =======
                    ZStack {
                        Image("SplashScreen_TalkBubble1")
                            .frame(width: geo.size.width * 0.9)
                        
                        Text("شرفتنا ونورتنا")
                            .font(.custom("Tajawal-Black", size: geo.size.width * 0.08))
                            .foregroundStyle(Color(.black))
                    }
                    .offset(x: bubble1Visible ? 0 : -geo.size.width)
                    .animation(.easeOut(duration: 0.7), value: bubble1Visible)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.4)
                    
                    // ======= step 2 — character =======
                    Image("SplashScreen_Character")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.8)
                        .rotationEffect(.degrees(characterTilted ? 25 : 10))
                        .offset(y: characterTilted ? -geo.size.height * 0.03 : 0)
                        .opacity(characterVisible ? 1 : 0)
                        .animation(.spring(duration: 0.5), value: characterVisible)
                        .animation(.spring(duration: 0.5), value: characterTilted)
                        .position(x: geo.size.width * 0.5, y: geo.size.height * 0.6)
                    
                    // ======= step 3 — talk bubble 2 =======
                    ZStack {
                        Image("SplashScreen_TalkBubble2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.9)
                        
                        Text("أنا أشرف")
                            .font(.custom("Tajawal-Black", size: geo.size.width * 0.08))
                            .foregroundStyle(Color(.black))
                            .rotationEffect(.degrees(-1))
                        
                    }
                    .opacity(bubble2Visible ? 1 : 0)
                    .animation(.easeOut(duration: 0.6), value: bubble2Visible)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.33)
                    
                    
                    // ======= step 6 — title =======
                    Image("GameName")
                        .scaleEffect(titleVisible ? 1 : 0)
                        .animation(.spring(duration: 0.4), value: titleVisible)
                        .position(x: geo.size.width * 0.5, y: geo.size.height * 0.23)
                    
                    // ======= step 7 — stars =======
                    Image("StarYellow")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.15)
                        .rotationEffect(.degrees(-10))
                        .position(x: geo.size.width * 0.2, y: geo.size.height * 0.06)
                        .scaleEffect(starsVisible ? 1 : 0)
                        .animation(.spring(duration: 0.5), value: starsVisible)
                    
                    Image("StarWhite")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.1)
                        .rotationEffect(.degrees(25))
                        .position(x: geo.size.width * 0.6, y: geo.size.height * 0.08)
                        .scaleEffect(starsVisible ? 1 : 0)
                        .animation(.spring(duration: 0.5), value: starsVisible)
                    
                    Image("StarRed")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.1)
                        .rotationEffect(.degrees(-20))
                        .position(x: geo.size.width * 0.8, y: geo.size.height * 0.04)
                        .scaleEffect(starsVisible ? 1 : 0)
                        .animation(.spring(duration: 0.5), value: starsVisible)
                    
                    
                    Image("StarWhite")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.1)
                        .rotationEffect(.degrees(25))
                        .position(x: geo.size.width * 0.2, y: geo.size.height * 0.4)
                        .scaleEffect(starsVisible ? 1 : 0)
                        .animation(.spring(duration: 0.5), value: starsVisible)
                    
                    Image("StarYellow")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.12)
                        .rotationEffect(.degrees(23))
                        .position(x: geo.size.width * 0.8, y: geo.size.height * 0.35)
                        .scaleEffect(starsVisible ? 1 : 0)
                        .animation(.spring(duration: 0.5), value: starsVisible)
                    
                    
                    
                    
                    // ======= step 8 — button =======
                    Button {
                        
                        
                    } label: {
                        ZStack {
                            ButtonView(width: geo.size.width * 0.5, height: geo.size.height * 0.09, fillColor: Color(.red), borderColor: .black)
                            Text("انطلق !")
                                .font(.custom("Lalezar-Regular", size: geo.size.width * 0.09))
                                .foregroundStyle(.white)
                        }
                    }
                    .opacity(buttonVisible ? 1 : 0)
                    .animation(.easeOut(duration: 0.5), value: buttonVisible)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.81)
                    
                    Button {
                        
                        
                    } label: {
                        ZStack {
                            ButtonView(width: geo.size.width * 0.5, height: geo.size.height * 0.09, fillColor: Color(.red), borderColor: .black)
                            Text("الإعدادات")
                                .font(.custom("Lalezar-Regular", size: geo.size.width * 0.09))
                                .foregroundStyle(.white)
                        }
                    }
                    .opacity(buttonVisible ? 1 : 0)
                    .animation(.easeOut(duration: 0.5), value: buttonVisible)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.93)
                    
                }
                .frame(width: geo.size.width, height: geo.size.height)
                
            }
            
        }
        .onAppear {
            
            // step 1 — bubble slides in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                bubble1Visible = true
            }
            
            // step 1 — bubble slides back out
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                bubble1Visible = false
            }
            
            // step 2 — character appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                characterVisible = true
            }
            
            // step 3 — bubble 2 appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                bubble2Visible = true
            }
            
            // step 4 — bubble 2 disappears
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.9) {
                bubble2Visible = false
            }
            
            // step 5 — character tilts and moves up
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                characterTilted = true
            }
            
            // step 6 — title appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                titleVisible = true
            }
            
            // step 7 — stars appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                starsVisible = true
            }
            
            // step 8 — button appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                buttonVisible = true
            }
            
        }
        
    }
}


#Preview {
    SplashScreen()
}
