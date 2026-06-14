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
        
    @State var userChoice: Choice = .player
    
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
                    TextTitle(text: "حدد موقعك!", fontName: "Lalezar-Regular", size: geo.size.width * 0.11, strokeWidth: 2, color: Color(.yellow))
                    
                    
                    Button {
                        userChoice = Choice.player
                        
                    } label: {
                        ZStack{
                            ButtonView(width: geo.size.width * 0.8, height: geo.size.width * 0.28, borderColor: userChoice == Choice.player ? Color(.red) : Color(.black))
                            PlayerOrVoterCardDesign(width: geo.size.width * 0.8, emoji: "🤾🏻", title: "لاعب", subTitle: "فاجئهم بشطحاتك !", circleColor: userChoice == Choice.player ? Color(.red) : Color(.black))
                            
                        }
                    }
                    
                    Button {
                        userChoice = Choice.voter
                        
                    } label: {
                        ZStack{
                            ButtonView(width: geo.size.width * 0.8, height: geo.size.width * 0.28, borderColor: userChoice == Choice.voter ? Color(.red) : Color(.black))
                            PlayerOrVoterCardDesign(width: geo.size.width * 0.8, emoji: "🧑🏻‍⚖️", title: "مصوّت", subTitle: "حدد الشطحة الرهيبة", circleColor: userChoice == Choice.voter ? Color(.red) : Color(.black))
                            
                        }
                    }
                    
                    Spacer().frame(height: geo.size.height * 0.3)
                    
                    Button {
                        
                        nav.push(.characterCustomization)
                        AudioManager.shared.playSound(SoundsList.popSound[0], fileExtension: SoundsList.popSound[1])
                        
                    } label: {
                        ZStack {
                            ButtonView(width: geo.size.width * 0.5, height: geo.size.height * 0.1, fillColor: Color(.red))
                            
                            Text("التالي").font(.custom("Lalezar-Regular", size: geo.size.width * 0.1)).foregroundStyle(.white)
                        }
                    }
                    
                }.frame(width: geo.size.width, height: geo.size.height)
                
                BackButton(geo: geo)
                
            } // end of GeometryReader
            
        }.navigationBarHidden(true) // end of ZStack
        
    }
}

struct PlayerOrVoterCardDesign: View {
    var width: CGFloat  // just width, not full size
    var emoji: String
    var title: String
    var subTitle: String
    var circleColor: Color = .black
    
    var body: some View {
        HStack {
            Spacer()
            // ======= text =======
            VStack(alignment: .trailing, spacing: 0) {
                Text(title)
                    .font(.custom("Lalezar-Regular", size: width * 0.1))
                    .foregroundStyle(.black)
                
                Text(subTitle)
                    .font(.custom("Tajawal-Bold", size: width * 0.05))
                    .foregroundStyle(.black)
            }
            
            Spacer().frame(width: width * 0.05)
            // ======= circle ======
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
