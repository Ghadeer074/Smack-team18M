//
//  SettingsScreen.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 10/06/2026.
//
import SwiftUI

struct SettingsScreen: View {
    
    @State private var musicOn = true
    @State private var soundOn = true
    
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
                    .padding()
                    
                    // ======= music toggle =======
                    ZStack {
                        ButtonView(width: geo.size.width * 0.85, height: geo.size.height * 0.1)
                        HStack {
                            Toggle("", isOn: $musicOn)
                                .tint(.yellow)
                                .labelsHidden()
                                .scaleEffect(1.2)
                            
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
                        if let url = URL(string: "https://forms.google.com") {
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
                    
                    // ======= VIP button =======
                    Button {
                        
                    } label: {
                        ZStack {
                            ButtonView(
                                width: geo.size.width * 0.85,
                                height: geo.size.height * 0.13,
                                fillColor: .white,
                                borderColor: Color(.red)
                            )
                            HStack {
                                Text("👑")
                                    .font(.system(size: geo.size.width * 0.12))
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("انضم لـ VIP اشطح!")
                                        .font(.custom("Tajawal-Black", size: geo.size.width * 0.06))
                                        .foregroundStyle(.black)
                                    
                                    Text("فئات حصرية، بدون إعلانات، ومزايا أكثر")
                                        .font(.custom("Tajawal-Bold", size: geo.size.width * 0.035))
                                        .foregroundStyle(.black)
                                }
                            }
                            .padding(.horizontal, geo.size.width * 0.06)
                            .frame(width: geo.size.width * 0.85)
                        }
                    }
                    
                    Spacer()
                    
                    // ======= version =======
                    Text("إصدار التطبيق v1.0.0")
                        .font(.custom("Tajawal-Bold", size: geo.size.width * 0.04))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.bottom, geo.size.height * 0.03)
                    
                }.frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}


#Preview {
    SettingsScreen()
}
