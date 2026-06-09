//
//  QuestionScreen.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 08/06/2026.
//
import SwiftUI
internal import Combine

struct QuestionScreen: View {
    @State private var timeRemaining = 30
    @State private var answer = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var move = false

    
    var body: some View {
        
        ZStack {
            Color(.blue).ignoresSafeArea()
            
            GeometryReader { geo in
                
                // ======= character =======
                Image("TinyCharacter")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.7)
                    .position(x: geo.size.width * 0.3, y: geo.size.height * 0.17)
                    .offset(y: move ? -5 : 0)
                    .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true), value: move)
                    .onAppear { move.toggle() }
                
                // ======= timer =======
                TextTitle(
                    text: String(format: "00:%02d", timeRemaining),
                    fontName: "Lalezar-Regular",
                    size: geo.size.width * 0.12,
                    strokeWidth: 1,
                    color: .yellow
                )
                .position(x: geo.size.width * 0.5, y: geo.size.height * 0.07)
                
                // =======================
                
                VStack(spacing: geo.size.height * 0.04) {
                    
                    Spacer().frame(height: geo.size.height * 0.12)
                    
                    // ======= question card =======
                    ZStack {
                        ButtonView(width: geo.size.width * 0.85, height: geo.size.height * 0.22, borderColor: Color(.red))
                        Text("ماهو الشي الذي لا يكتمل العيد بدونه؟")
                            .font(.custom("Tajawal-Black", size: geo.size.width * 0.06))
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                            .lineSpacing(10)
                            .frame(width: geo.size.width * 0.75, height: geo.size.height * 0.17)
                            .padding()
                    }
                    
                    
                    // ======= answer text field =======
                    ZStack {
                        ButtonView(width: geo.size.width * 0.75, height: geo.size.height * 0.2)
                        ZStack(alignment: .topTrailing) {
                            if answer.isEmpty {
                                Text("اكتب ردك هنا...")
                                    .font(.custom("Tajawal-Bold", size: geo.size.width * 0.05))
                                    .foregroundStyle(.gray)
                                    .padding(.top, 8)
                                    .padding(.trailing, 8)
                            }
                            TextEditor(text: $answer)
                                .font(.custom("Tajawal-Bold", size: geo.size.width * 0.06))
                                .frame(width: geo.size.width * 0.65, height: geo.size.height * 0.15)
                                .scrollContentBackground(.hidden)
                                .multilineTextAlignment(.trailing)
                        }
                        .frame(width: geo.size.width * 0.65, height: geo.size.height * 0.15)
                    }
                    
                    Spacer().frame(height: geo.size.height * 0.12)
                    
                    // ======= submit button =======
                    Button {
                        
                    } label: {
                        ZStack {
                            ButtonView(width: geo.size.width * 0.45, height: geo.size.height * 0.103, fillColor: Color(.red))
                            Text("اشطح !")
                                .font(.custom("Lalezar-Regular", size: geo.size.width * 0.09))
                                .foregroundStyle(.white)
                        }
                    }
                    
                }.frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                // When the 30 seconds are done, we're gonna add what to do (mostly make the answer = "معرفش" or "..." and move to next screen (voting)
                
                timer.upstream.connect().cancel()
            }
        }
        
    }
}

#Preview {
    QuestionScreen()
}
