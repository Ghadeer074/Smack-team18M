//
//  SettingsScreen.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 10/06/2026.
//
import SwiftUI

struct SettingsScreen: View {

    @Environment(NavigationManager.self) private var nav

    @State private var musicOn: Bool = AudioManager.shared.musicEnabled
    @State private var soundOn: Bool = AudioManager.shared.sfxEnabled

    @State private var showVIPPopup = false

    var body: some View {
        ZStack {
            Color(.blue).ignoresSafeArea()

            GeometryReader { geo in
                VStack(spacing: geo.size.height * 0.03) {

                    // ======= title =======
                    TextTitle(
                        text: "الإعدادات",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.12,
                        strokeWidth: 2
                    )
                    .rotationEffect(.degrees(-2))
                    .padding(.top, geo.size.height * 0.08)

                    // ======= music toggle =======
                    ZStack {
                        ButtonView(width: geo.size.width * 0.85, height: geo.size.height * 0.1)
                        HStack {
                            Toggle("", isOn: $musicOn)
                                .tint(.yellow)
                                .labelsHidden()
                                .scaleEffect(1.2)
                                .onChange(of: musicOn) {
                                    AudioManager.shared.musicEnabled = musicOn
                                    if musicOn {
                                        AudioManager.shared.playMusic("GameMUsic")
                                    } else {
                                        AudioManager.shared.stopMusic()
                                    }
                                }

                            Spacer()

                            Text("🎵 موسيقى اللعبة")
                                .font(.custom("Tajawal-Bold", size: geo.size.width * 0.055))
                                .foregroundStyle(.black)
                        }
                        .padding(.horizontal, geo.size.width * 0.08)
                        .frame(width: geo.size.width * 0.85)
                    }

                    // ======= sound effects toggle =======
                    ZStack {
                        ButtonView(width: geo.size.width * 0.85, height: geo.size.height * 0.1)
                        HStack {
                            Toggle("", isOn: $soundOn)
                                .tint(.yellow)
                                .labelsHidden()
                                .scaleEffect(1.2)
                                .onChange(of: soundOn) {
                                    AudioManager.shared.sfxEnabled = soundOn
                                }

                            Spacer()

                            Text("🔊 المؤثرات الصوتية")
                                .font(.custom("Tajawal-Bold", size: geo.size.width * 0.055))
                                .foregroundStyle(.black)
                        }
                        .padding(.horizontal, geo.size.width * 0.08)
                        .frame(width: geo.size.width * 0.85)
                    }

                    // ======= support button =======
                    Button {
                        if let url = URL(string: "https://forms.gle/TvUDhsWy6LY32viu8") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        ZStack {
                            ButtonView(
                                width: geo.size.width * 0.85,
                                height: geo.size.height * 0.09,
                                fillColor: Color(red: 0.15, green: 0.15, blue: 0.15)
                            )
                            HStack {
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(.white)
                                Spacer()
                                Text("💬 الدعم والمقترحات")
                                    .font(.custom("Tajawal-Bold", size: geo.size.width * 0.055))
                                    .foregroundStyle(.white)
                            }
                            .padding(.horizontal, geo.size.width * 0.08)
                            .frame(width: geo.size.width * 0.85)
                        }
                    }

                    // ======= VIP button (disabled, shows popup) =======
                    Button {
                        showVIPPopup = true
                    } label: {
                        ZStack {
                            ButtonView(
                                width: geo.size.width * 0.85,
                                height: geo.size.height * 0.13,
                                fillColor: .white.opacity(0.5),
                                borderColor: Color(.red).opacity(0.5)
                            )
                            HStack {
                                Text("👑")
                                    .font(.system(size: geo.size.width * 0.12))
                                    .opacity(0.5)

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("انضم لـ VIP اشطح!")
                                        .font(.custom("Tajawal-Black", size: geo.size.width * 0.06))
                                        .foregroundStyle(.black.opacity(0.4))

                                    Text("قريباً...")
                                        .font(.custom("Tajawal-Bold", size: geo.size.width * 0.04))
                                        .foregroundStyle(.black.opacity(0.4))
                                }
                            }
                            .padding(.horizontal, geo.size.width * 0.06)
                            .frame(width: geo.size.width * 0.85)

                            // "قريباً" badge
                            Text("🔒 قريباً")
                                .font(.custom("Tajawal-Black", size: geo.size.width * 0.04))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(.red).opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .offset(x: -geo.size.width * 0.28, y: -geo.size.height * 0.05)
                        }
                    }

                    Spacer()

                    // ======= version =======
                    Text("إصدار التطبيق v1.0.0")
                        .font(.custom("Tajawal-Bold", size: geo.size.width * 0.04))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.bottom, geo.size.height * 0.03)

                }.frame(width: geo.size.width, height: geo.size.height)

                // ======= back button =======
                BackButton(geo: geo)
            }

            // ======= VIP popup overlay =======
            if showVIPPopup {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture { showVIPPopup = false }

                VIPPopup(isVisible: $showVIPPopup)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.3), value: showVIPPopup)
        .navigationBarHidden(true)
    }
}

// ======= VIP popup =======
struct VIPPopup: View {
    @Binding var isVisible: Bool

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ButtonView(
                    width: geo.size.width * 0.8,
                    height: geo.size.height * 0.32,
                    fillColor: Color(.blue),
                    borderColor: Color(.yellow),
                    shadowWidth: 6
                )

                VStack(spacing: geo.size.height * 0.02) {
//                    Text("👑")
//                        .font(.system(size: geo.size.width * 0.15))

                    TextTitle(
                        text: "قريباً !",
                        fontName: "Lalezar-Regular",
                        size: geo.size.width * 0.12,
                        strokeWidth: 1,
                        color: Color(.yellow)
                    )

                    Text("ميزة الـ VIP ما طلعت بعد،\nترقبوها قريباً!")
                        .font(.custom("Tajawal-Bold", size: geo.size.width * 0.045))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Button {
                        isVisible = false
                    } label: {
                        ZStack {
                            ButtonView(
                                width: geo.size.width * 0.4,
                                height: geo.size.height * 0.065,
                                fillColor: Color(.red),
                                borderColor: .black,
                                shadowWidth: 4
                            )
                            Text("حسناً")
                                .font(.custom("Lalezar-Regular", size: geo.size.width * 0.07))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

#Preview {
    SettingsScreen()
        .environment(NavigationManager())
}
