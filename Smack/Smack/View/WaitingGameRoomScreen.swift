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
    
    @State private var move = false
    
    @Environment(NavigationManager.self) private var nav
    
    var body: some View {
        
        ZStack {
            Color(.blue).ignoresSafeArea()
            
            GeometryReader { geo in
                Image("TinyCharacter")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.7)
                    .rotationEffect(.degrees(25))
                    .position(
                        x: geo.size.width * 0.1,
                        y: geo.size.height * 1
                    )
                    .offset(
                        x: move ? 8 : 0,
                        y: move ? -8 : 0
                    )
                
                    .animation(.easeInOut(duration: 1.3)
                        .repeatForever(autoreverses: true),
                               value: move
                    )
                
                    .onAppear {
                        move.toggle()
                    }
                
                
                
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
                                .padding()
                            
                            Text("B8G7")
                                .tracking(15)
                                .font(.custom("Tajawal-Black", size: geo.size.width * 0.12))
                                .foregroundStyle(.black)
                        }
                    }
                    
                    // ======= share button =======
                    Button {
                        
                    } label: {
                        ZStack {
                            ButtonView(width: geo.size.width * 0.45, height: geo.size.height * 0.06, fillColor: .black, borderColor: Color(.red))
                            Text("🔗 شارك الرابط")
                                .font(.custom("Tajawal-Bold", size: geo.size.width * 0.045))
                                .foregroundStyle(.white)
                        }
                    }
                    
                    // ======= waiting text =======
                    TextTitle(
                        text: "ننتظر اللاعبين... (\(players.count)/\(maxPlayers))",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.055,
                        strokeWidth: 0.5,
                        color: Color(.yellow)
                    )
                    .frame(width: geo.size.width * 0.9, alignment: .trailing) // right aligned
                    
                    // ======= players grid =======
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: geo.size.height * 0.02) {
                            
                            // joined players
                            ForEach(players, id: \.self) { player in
                                VStack(spacing: 4) {
                                    ZStack {
                                        CircleView(size: geo.size.width * 0.24)
                                        
                                        Image("TinyCharacter")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: geo.size.width * 0.25)
                                    }.padding(.bottom, 2)
                                    
                                    Text(player)
                                        .font(.custom("Tajawal-Black", size: geo.size.width * 0.04))
                                        .foregroundStyle(.white)
                                }
                            }
                            
                            
                            
                        }
                        .environment(\.layoutDirection, .rightToLeft)
                        .padding(.horizontal, geo.size.width * 0.05)
                    }
                    
                    // ======= start button =======
                    Button {
                        
                    } label: {
                        ZStack {
                            ButtonView(width: geo.size.width * 0.4, height: geo.size.height * 0.1, fillColor: Color(.red))
                            
                            Text("ابدأ !")
                                .font(.custom("Lalezar-Regular", size: geo.size.width * 0.08))
                                .foregroundStyle(.white)
                                
                            
                        }.padding(.vertical)
                    }
                    
                }.frame(width: geo.size.width, height: geo.size.height)
                
                BackButton(geo: geo)
                
            }
            
        }.navigationBarHidden(true)
        
    }
}

#Preview {
    WaitingGameRoomScreen().environment(NavigationManager())

}
