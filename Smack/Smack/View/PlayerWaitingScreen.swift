//
//  PlayerWaitingScreen.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 09/06/2026.
//
import SwiftUI

struct PlayerWaitingScreen: View {
    var body: some View {
        
        ZStack {
            
            Color(.blue).ignoresSafeArea()
            
            
            GeometryReader { geo in
                
                VStack {
                    TextTitle(
                        text: "تم إرسال إجابتك !",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.12,
                        strokeWidth: 1,
                        color: Color(.yellow)
                    )
                    .rotationEffect(.degrees(-2))
                    
                    
                    ZStack {
                        ButtonView(width: geo.size.width * 0.8, height: geo.size.height * 0.13)
                        
                        Text("في انتظار التصويت...")
                            .font(.custom("Tajawal-Black", size: geo.size.width * 0.06))
                        
                    }.rotationEffect(.degrees(2))
                    
                    
                    // USER Character
                    
                    Image("TinyCharacter")
                        .resizable()
                        .scaledToFit()
                        .border(.red)
                    
                    
                    
                    
                    
                    
                }.frame(width: geo.size.width, height: geo.size.height)
                                
            } // end of GeometryReader
            
        } // end of ZStack
        
        
    }
}

#Preview {
    PlayerWaitingScreen()
}
