//
//  PlayerWaitingScreen.swift
//  Smack
//
import SwiftUI

struct PlayerWaitingScreen: View {

    @Environment(NavigationManager.self) private var nav
    @State private var vm = PlayerWaitingViewModel()

    var body: some View {
        ZStack {
            Color(.blue).ignoresSafeArea()

            GeometryReader { geo in
                VStack(spacing: geo.size.height * 0.04) {

                    TextTitle(
                        text: "تم إرسال إجابتك !",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.12,
                        strokeWidth: 1,
                        color: Color(.yellow)
                    )
                    .rotationEffect(.degrees(-2))
                    .padding(.top, geo.size.height * 0.1)

                    ZStack {
                        ButtonView(width: geo.size.width * 0.8, height: geo.size.height * 0.13)
                        VStack(spacing: 4) {
                            Text("التصويت يبدأ بعد")
                                .font(.custom("Tajawal-Bold", size: geo.size.width * 0.04))
                                .foregroundStyle(.gray)
                            TextTitle(
                                text: "\(vm.timeRemaining)ث",
                                fontName: "Lalezar-Regular",
                                size: geo.size.width * 0.12,
                                strokeWidth: 1,
                                color: vm.timeRemaining <= 5 ? .red : Color(.black)
                            )
                        }
                    }.rotationEffect(.degrees(2))

                    Image("TinyCharacter")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.55)

                }.frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            let createdAt = nav.currentSessionQuestion?.createdAt ?? Date()
            vm.startWaiting(questionCreatedAt: createdAt)
        }
        .onDisappear { vm.stopTimer() }
        .onChange(of: vm.readyToVote) { _, ready in
            if ready { nav.push(.votingScreen) }
        }
    }
}
