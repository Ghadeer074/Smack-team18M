//
//  PlayerOrVoterScreen.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 28/05/2026.
//
import SwiftUI

struct PlayerOrVoterScreen: View {
        
    enum Choice {
        case player, voter
    }
    
    @Environment(NavigationManager.self) private var nav
    @State var userChoice: Choice?
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
                    .position(x: geo.size.width * 0.9, y: geo.size.height * -0.03)
                    .offset(y: move ? -8 : 1)
                    .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true), value: move)
                    .onAppear { move.toggle() }
                
                VStack {
                    TextTitle(
                        text: "حدد موقعك!",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.11,
                        strokeWidth: 2,
                        color: Color(.yellow)
                    )
                    
                    Button {
                        userChoice = userChoice == .player ? nil : .player
                    } label: {
                        ZStack {
                            ButtonView(
                                width: geo.size.width * 0.8,
                                height: geo.size.width * 0.28,
                                borderColor: userChoice == .player ? Color(.red) : Color(.black)
                            )
                            PlayerOrVoterCardDesign(
                                width: geo.size.width * 0.8,
                                emoji: "🤾🏻",
                                title: "لاعب",
                                subTitle: "فاجئهم بشطحاتك !",
                                circleColor: userChoice == .player ? Color(.red) : Color(.black)
                            )
                        }
                    }
                    
                    Button {
                        userChoice = userChoice == .voter ? nil : .voter
                    } label: {
                        ZStack {
                            ButtonView(
                                width: geo.size.width * 0.8,
                                height: geo.size.width * 0.28,
                                borderColor: userChoice == .voter ? Color(.red) : Color(.black)
                            )
                            PlayerOrVoterCardDesign(
                                width: geo.size.width * 0.8,
                                emoji: "🧑🏻‍⚖️",
                                title: "مصوّت",
                                subTitle: "حدد الشطحة الرهيبة",
                                circleColor: userChoice == .voter ? Color(.red) : Color(.black)
                            )
                        }
                    }
                    
                    Spacer().frame(height: geo.size.height * 0.3)
                    
                    Button {
                        // ── نحفظ الدور في nav ──
                        nav.selectedRole = userChoice == .player ? "player" : "voter"
                        nav.push(.characterCustomization)
                    } label: {
                        ZStack {
                            ButtonView(
                                width: geo.size.width * 0.5,
                                height: geo.size.height * 0.1,
                                fillColor: userChoice == nil ? Color(.gray) : Color(.red)
                            )
                            Text("التالي")
                                .font(.custom("Lalezar-Regular", size: geo.size.width * 0.1))
                                .foregroundStyle(.white)
                        }
                    }
                    .disabled(userChoice == nil)
                    
                }.frame(width: geo.size.width, height: geo.size.height)
                
                BackButton(geo: geo)
            }
        }.navigationBarHidden(true)
    }
}

struct PlayerOrVoterCardDesign: View {
    var width: CGFloat
    var emoji: String
    var title: String
    var subTitle: String
    var circleColor: Color = .black
    
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                Text(title)
                    .font(.custom("Lalezar-Regular", size: width * 0.1))
                    .foregroundStyle(.black)
                Text(subTitle)
                    .font(.custom("Tajawal-Bold", size: width * 0.05))
                    .foregroundStyle(.black)
            }
            Spacer().frame(width: width * 0.05)
            ZStack {
                Circle()
                    .frame(width: width * 0.2, height: width * 0.2)
                    .foregroundStyle(circleColor)
                Text(emoji)
                    .font(.system(size: width * 0.1))
            }
            Spacer().frame(width: width * 0.07)
        }
        .frame(width: width)
    }
}

#Preview {
    PlayerOrVoterScreen().environment(NavigationManager())
}
