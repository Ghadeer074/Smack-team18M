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
    
    @State var userChoice: Choice?
    
    @State var clicked: Bool = false
    
    var body: some View {
        
        ZStack {
            Color(.blue).ignoresSafeArea()
            
            GeometryReader { geo in
                
                VStack {
                    TextTitle(text: "حدد موقعك!", fontName: "Lalezar-Regular", size: geo.size.width * 0.11, strokeWidth: 2, color: Color(.yellow))
                    
                    
                    Button {
                        userChoice = Choice.player
                        
                    } label: {
                        ZStack{
                            ButtonView(width: geo.size.width * 0.8, height: geo.size.width * 0.28)
                            PlayerOrVoterCardDesign(width: geo.size.width * 0.8, emoji: "🤾🏻", title: "لاعب", subTitle: "فاجئهم بشطحاتك!")
                            
                        }
                    }
                    
                    Button {
                        
                    } label: {
                        ZStack{
                            ButtonView(width: geo.size.width * 0.8, height: geo.size.width * 0.28)
                            PlayerOrVoterCardDesign(width: geo.size.width * 0.8, emoji: "🧑🏻‍⚖️", title: "مصوّت", subTitle: "ايش الشطحة الرهيبة")
                            
                        }
                    }
                    
                    
                    
                    
                }.frame(width: geo.size.width, height: geo.size.height)
                
            } // end of GeometryReader
            
        } // end of ZStack
        
    }
}

struct PlayerOrVoterCardDesign: View {
    var width: CGFloat  // just width, not full size
    var emoji: String
    var title: String
    var subTitle: String
    
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
                    .foregroundStyle(.black)
                Text(emoji)
                    .font(.system(size: width * 0.1))
            }
            
            Spacer().frame(width: width * 0.07)
        }
        .frame(width: width)
    }
}

#Preview {
    PlayerOrVoterScreen()
}
