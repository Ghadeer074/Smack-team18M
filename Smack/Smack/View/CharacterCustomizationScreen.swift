//
//  CharacterCustomizationScreen.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 11/06/2026.
//
import SwiftUI
import CloudKit

enum CustomizationCategory: String, CaseIterable {
    case headwear, eyes, mouth, color
    
    var icon: String {
        switch self {
        case .headwear: return "Icon_Headwear"
        case .eyes:     return "Icon_Eyes"
        case .mouth:    return "Icon_Mouth"
        case .color:    return "Icon_Color"
        }
    }
}

struct CharacterCustomizationScreen: View {
    
    @Environment(NavigationManager.self) private var nav
    @State private var vm = CharacterCustomizationViewModel()

    @State private var playerName: String = ""
    @State private var selectedCategory: CustomizationCategory = .headwear
    @State private var selections: [CustomizationCategory: Int] = [
        .headwear: 0, .eyes: 0, .mouth: 0, .color: 0
    ]
    
    let optionCounts: [CustomizationCategory: Int] = [
        .headwear: 5, .eyes: 4, .mouth: 4, .color: 5
    ]
    
    var body: some View {
        ZStack {
            Color(.blue).ignoresSafeArea()
            
            GeometryReader { geo in
                VStack(spacing: geo.size.height * 0.025) {
                    
                    // ======= title =======
                    TextTitle(
                        text: "صمم شخصيتك",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.11,
                        strokeWidth: 2,
                        color: Color(.yellow)
                    )
                    .rotationEffect(.degrees(-2))
                    .padding(.top, geo.size.height * 0.1)
                    
                    // ======= category selector =======
                    ZStack {
                        ButtonView(
                            width: geo.size.width * 0.85,
                            height: geo.size.height * 0.13,
                            fillColor: .white,
                            borderColor: .black,
                            shadowWidth: 5
                        )
                        HStack(spacing: geo.size.width * 0.04) {
                            ForEach(CustomizationCategory.allCases, id: \.self) { category in
                                Button {
                                    selectedCategory = category
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white)
                                            .frame(width: geo.size.width * 0.16, height: geo.size.width * 0.16)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        selectedCategory == category ? Color(.red) : Color(.black),
                                                        lineWidth: selectedCategory == category ? 4 : 3
                                                    )
                                            )
                                        Image(category.icon)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: geo.size.width * 0.1)
                                    }
                                }
                            }
                        }
                    }.padding(.bottom, geo.size.width * 0.1)
                    
                    // ======= character preview =======
                    ZStack {
                        Image("CharacterBase_\(selections[.color] ?? 0)")
                            .resizable().scaledToFit()
                            .frame(width: geo.size.width * 0.55)
                        Image("Eyes_\(selections[.eyes] ?? 0)")
                            .resizable().scaledToFit()
                            .frame(width: geo.size.width * 0.55)
                        Image("Mouth_\(selections[.mouth] ?? 0)")
                            .resizable().scaledToFit()
                            .frame(width: geo.size.width * 0.55)
                        Image("Headwear_\(selections[.headwear] ?? 0)")
                            .resizable().scaledToFit()
                            .frame(width: geo.size.width * 0.55)
                        
                        HStack {
                            Button { changeOption(by: -1) } label: {
                                ZStack {
                                    ButtonView(width: geo.size.width * 0.16, height: geo.size.width * 0.16, fillColor: Color(.red), borderColor: Color(.black), shadowWidth: 4)
                                    Image(systemName: "play.fill")
                                        .foregroundStyle(.white)
                                        .font(.system(size: geo.size.width * 0.05))
                                        .rotationEffect(.degrees(180))
                                }
                            }
                            Spacer()
                            Button { changeOption(by: 1) } label: {
                                ZStack {
                                    ButtonView(width: geo.size.width * 0.16, height: geo.size.width * 0.16, fillColor: Color(.red), borderColor: Color(.black), shadowWidth: 4)
                                    Image(systemName: "play.fill")
                                        .foregroundStyle(.white)
                                        .font(.system(size: geo.size.width * 0.05))
                                }
                            }
                        }
                        .frame(width: geo.size.width * 0.85)
                    }
                    .frame(height: geo.size.height * 0.25)

                    // ======= player name =======
                    TextTitle(
                        text: "اسم اللاعب:",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.08,
                        strokeWidth: 0.5,
                        color: Color(.yellow)
                    )
                    .padding(.top, -geo.size.height * 0.02)
                    
                    ZStack {
                        ButtonView(width: geo.size.width * 0.7, height: geo.size.height * 0.09, fillColor: .white, borderColor: .black, shadowWidth: 5)
                        TextField(". . .", text: $playerName)
                            .font(.custom("Tajawal-Bold", size: geo.size.width * 0.08))
                            .foregroundStyle(Color.black)
                            .multilineTextAlignment(.center)
                            .frame(width: geo.size.width * 0.75)
                    }

                    // ======= error =======
                    if let error = vm.errorMessage {
                        Text(error)
                            .font(.custom("Tajawal-Bold", size: geo.size.width * 0.04))
                            .foregroundStyle(Color(.red))
                    }
                    
                    Spacer()
                    
                    // ======= next button =======
                    Button {
                        Task {
                            if let session = nav.currentSession {
                                await vm.joinAsPlayer(
                                    name: playerName,
                                    session: session,
                                    role: nav.selectedRole,
                                    isHost: nav.isHost
                                )
                            }
                        }
                    } label: {
                        ZStack {
                            ButtonView(
                                width: geo.size.width * 0.45,
                                height: geo.size.height * 0.085,
                                fillColor: vm.isLoading ? Color(.gray) : Color(.red)
                            )
                            if vm.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("التالي")
                                    .font(.custom("Lalezar-Regular", size: geo.size.width * 0.085))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .disabled(vm.isLoading || nav.currentPlayer != nil)
                    .padding(.bottom, geo.size.height * 0.1)
                    
                }.frame(width: geo.size.width, height: geo.size.height)
                
                BackButton(geo: geo)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            vm.playerCreated = false
            vm.errorMessage = nil
        }
        .onDisappear {
            // ── if navigating back (not forward), delete player record to free slot ──
            if !vm.playerCreated {
                Task {
                    if let session = nav.currentSession {
                        let deviceID = DeviceManager.shared.deviceID
                        let players = try? await CloudKitManager.shared.fetchPlayers(forsession: session.id)
                        if let existing = players?.first(where: { $0.deviceID == deviceID }),
                           let recordID = existing.recordID {
                            try? await CKContainer(identifier: "iCloud.com.Smack")
                                .publicCloudDatabase.deleteRecord(withID: recordID)
                        }
                    }
                }
            }
        }
        .onChange(of: vm.playerCreated) { _, created in
            if created {
                nav.currentPlayer = vm.createdPlayer
                nav.push(.waitingGameRoom)
                vm.playerCreated = false
            }
        }
    }
    
    private func changeOption(by step: Int) {
        let count = optionCounts[selectedCategory] ?? 1
        var current = selections[selectedCategory] ?? 0
        current = (current + step + count) % count
        selections[selectedCategory] = current
    }
}

#Preview {
    CharacterCustomizationScreen().environment(NavigationManager())
}
