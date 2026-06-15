//
//  SubscriptionPageScreen.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 10/06/2026.
//

import SwiftUI

struct SubscriptionPageScreen: View {
    
    @State private var selectedPlan: String = "yearly"
    
    var body: some View {
        ZStack {
            Color(.blue).ignoresSafeArea()
            
            GeometryReader { geo in
                //ScrollView {
                    VStack(spacing: geo.size.height * 0.03) {
                        
                        // ======= title =======
                        TextTitle(
                            text: "اشتراك الـ VIP",
                            fontName: "Lalezar-Regular",
                            size: geo.size.width * 0.12,
                            strokeWidth: 2,
                            color: .white
                        )
                        .rotationEffect(.degrees(-2))
                        
                        // ======= features card =======
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(.yellow, lineWidth: 3)
                                )
                            
                            VStack(alignment: .trailing, spacing: geo.size.height * 0.02) {
                                FeatureRow(text: "فئات أسئلة حصرية وشطحات لا تنتهي", geo: geo)
                                FeatureRow(text: "بدون أي إعلانات مزعجة", geo: geo)
                                FeatureRow(text: "الوان واكسسوارات شخصيات اكثر للأفاتار حقك", geo: geo)
                                FeatureRow(text: "صلاحية إنشاء غرف بـ 12 لاعب (بدل 3)", geo: geo)
                            }
                            .padding(geo.size.width * 0.05)
                        }
                        .frame(width: geo.size.width * 0.85)
                        .padding(.horizontal, geo.size.width * 0.075)
                        
                        // ======= yearly plan =======
                        Button {
                            selectedPlan = "yearly"
                        } label: {
                            ZStack(alignment: .topLeading) {
                                ButtonView(
                                    width: geo.size.width * 0.85,
                                    height: geo.size.height * 0.14,
                                    fillColor: selectedPlan == "yearly" ? Color(.yellow) : Color(.white),
                                    borderColor: selectedPlan == "yearly" ? Color(.red) : .black
                                )
                                .overlay(alignment: .topLeading) {
                                    Text("أفضل توفير ! 🔥")
                                        .font(.custom("Tajawal-Black", size: geo.size.width * 0.035))
                                        .foregroundStyle(.white)
                                        .frame(width: geo.size.width * 0.31, height: geo.size.height * 0.04, alignment: .center)
                                        .background(Color(.red))
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(.black, lineWidth: 2)
                                        )
                                        .padding(.leading, geo.size.width * 0.04)
                                        .padding(.top, -geo.size.height * 0.018)
                                }
                                
                                HStack {
                                    // price
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("59.99")
                                            .font(.custom("Lalezar-Regular", size: geo.size.width * 0.1))
                                            .foregroundStyle(Color(.black))
                                        Text("ريال / سنة")
                                            .font(.custom("Tajawal-Bold", size: geo.size.width * 0.04))
                                            .foregroundStyle(.black)
                                    }
                                    
                                    Spacer()
                                    
                                    // plan name
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("اشتراك سنوي")
                                            .font(.custom("Lalezar-Regular", size: geo.size.width * 0.07))
                                            .foregroundStyle(.black)
                                        Text("تجديد تلقائي كل سنة")
                                            .font(.custom("Tajawal-Bold", size: geo.size.width * 0.035))
                                            .foregroundStyle(.black.opacity(0.6))
                                    }
                                }
                                .padding(.horizontal, geo.size.width * 0.06)
                                .frame(width: geo.size.width * 0.85, height: geo.size.height * 0.14)
                            }
                        }
                        
                        // ======= monthly plan =======
                        Button {
                            selectedPlan = "monthly"
                        } label: {
                            ZStack {
                                ButtonView(
                                    width: geo.size.width * 0.85,
                                    height: geo.size.height * 0.14,
                                    fillColor: selectedPlan == "monthly" ? Color(.yellow) : Color(.white),
                                    borderColor: selectedPlan == "monthly" ? Color(.red) : .black
                                )
                                
                                HStack {
                                    // price
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("8.99")
                                            .font(.custom("Lalezar-Regular", size: geo.size.width * 0.1))
                                            .foregroundStyle(.black)
                                        Text("ريال / شهر")
                                            .font(.custom("Tajawal-Bold", size: geo.size.width * 0.04))
                                            .foregroundStyle(.black)
                                    }
                                    
                                    Spacer()
                                    
                                    // plan name
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("اشتراك شهري")
                                            .font(.custom("Lalezar-Regular", size: geo.size.width * 0.07))
                                            .foregroundStyle(.black)
                                        Text("تجديد تلقائي كل شهر")
                                            .font(.custom("Tajawal-Bold", size: geo.size.width * 0.035))
                                            .foregroundStyle(.black.opacity(0.6))
                                    }
                                }
                                .padding(.horizontal, geo.size.width * 0.06)
                                .frame(width: geo.size.width * 0.85)
                            }
                        }
                        
                        Spacer().frame(height: geo.size.height * 0.05)
                        
                        // ======= subscribe button =======
                        ZStack {
                            ButtonView(
                                width: geo.size.width * 0.7,
                                height: geo.size.height * 0.1,
                                fillColor: Color(.red),
                                borderColor: .black
                            )
                            Text("اشترك الحين!")
                                .font(.custom("Lalezar-Regular", size: geo.size.width * 0.08))
                                .foregroundStyle(.white)
                        }
                        
                        // ======= terms =======
                        Text("شروط الاستخدام وسياسة الخصوصية تطبق. يمكنك إلغاء الاشتراك بأي وقت.")
                            .font(.custom("Tajawal-Bold", size: geo.size.width * 0.035))
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, geo.size.width * 0.08)
                            .padding(.bottom, geo.size.height * 0.03)
                        
                    }
                    .frame(width: geo.size.width)
                    .padding(.top, geo.size.height * 0.02)
                }
            }
        //}
    }
}

// ======= feature row helper =======
struct FeatureRow: View {
    let text: String
    let geo: GeometryProxy
    
    var body: some View {
        HStack(spacing: 12) {
            
            Text(text)
                .font(.custom("Tajawal-Bold", size: geo.size.width * 0.04))
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
            Text("⚡️")
                .font(.system(size: geo.size.width * 0.05))
        }
    }
}

#Preview {
    SubscriptionPageScreen()
}
