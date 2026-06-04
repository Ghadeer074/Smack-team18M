//
//  WaitingGameRoomScreen.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 04/06/2026.
//
import SwiftUI

struct WaitingGameRoomScreen: View {
    
    let players = ["سارة", "الجوهرة", "طيف", "مها"]
    let maxPlayers = 6
    
    var body: some View {
        
        ZStack {
            Color(.blue).ignoresSafeArea()
            
            GeometryReader { geo in
                VStack(spacing: geo.size.height * 0.02) {
                    
                    // ======= title =======
                    TextTitle(text: "الغرفة جاهزة !", fontName: "Lalezar-Regular", size: geo.size.width * 0.12, strokeWidth: 2)
                        .rotationEffect(.degrees(-2))
                    
                    // ======= room code card =======
                    ZStack {
                        ButtonView(width: geo.size.width * 0.8, height: geo.size.height * 0.18, borderColor: Color(.red))
                        VStack(spacing: 4) {
                            Text("كود الغرفة")
                                .font(.custom("Tajawal-Bold", size: geo.size.width * 0.05))
                                .foregroundStyle(.gray)
                            
                            Text("B8G7")
                                .tracking(15)
                                .font(.custom("Tajawal-Black", size: geo.size.width * 0.12))
                                .foregroundStyle(.black)
                        }
                    }
                    
                    // ======= share button =======
                    ZStack {
                        ButtonView(width: geo.size.width * 0.45, height: geo.size.height * 0.055, fillColor: .black, borderColor: .red)
                        Text("🔗 شارك الرابط")
                            .font(.custom("Tajawal-Bold", size: geo.size.width * 0.045))
                            .foregroundStyle(.white)
                    }
                    
                    // ======= waiting text =======
                    TextTitle(
                        text: "ننتظر اللاعبين... (\(players.count)/\(maxPlayers))",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.055,
                        strokeWidth: 0.5,
                        color: Color(.yellow)
                    )
                    
                    // ======= players grid =======
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: geo.size.height * 0.02) {
                        
                        // joined players
                        ForEach(players, id: \.self) { player in
                            VStack(spacing: 4) {
                                ZStack {
                                    CircleView(size: geo.size.width * 0.25)
                                    
                                    Image("PlayerAvatar")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geo.size.width * 0.18)
                                }
                                
                                Text(player)
                                    .font(.custom("Tajawal-Bold", size: geo.size.width * 0.04))
                                    .foregroundStyle(.black)
                            }
                        }
                        
                        
                        
                    }
                    .environment(\.layoutDirection, .rightToLeft)
                    .padding(.horizontal, geo.size.width * 0.05)
                    
                    Spacer()
                    
                    // ======= start button =======
                    ZStack {
                        ButtonView(width: geo.size.width * 0.6, height: geo.size.height * 0.08, fillColor: .red, borderColor: .black)
                        Text("ابدأ !")
                            .font(.custom("Tajawal-Black", size: geo.size.width * 0.1))
                            .foregroundStyle(.white)
                    }
                    .padding(.bottom, geo.size.height * 0.03)
                    
                }.frame(width: geo.size.width, height: geo.size.height)
                
            }
            
        }
        
    }
}

#Preview {
    WaitingGameRoomScreen()
}
