//
//  HelperViews.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 27/05/2026.
//
import SwiftUI

// ============= used to add buttons =================

struct ButtonView: View {
    var width: CGFloat
    var height: CGFloat
    var fillColor: Color = .white
    var borderColor: Color = .black
    
    var body: some View {
        ZStack {
            // shadow rectangle
            RoundedRectangle(cornerRadius: 20)
                .fill(borderColor)
                .frame(width: width, height: height)
                .offset(x: 10, y: 10)
            
            // main rectangle
            RoundedRectangle(cornerRadius: 20)
                .fill(fillColor)
                .frame(width: width, height: height)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.black, lineWidth: 4)
                )
        }
    }
}
// ============= used to make circle buttons =================
struct CircleView: View {
    var size: CGFloat
    var fillColor: Color = .white
    var borderColor: Color = .black
    var isDashed: Bool = false
    
    var body: some View {
        ZStack {
            // shadow circle
            Circle()
                .fill(borderColor)
                .frame(width: size, height: size)
                .offset(x: -3, y: 4)
            
            // main circle
            Circle()
                .fill(fillColor)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .strokeBorder(
                            style: isDashed
                                ? StrokeStyle(lineWidth: 3, dash: [8])
                                : StrokeStyle(lineWidth: 3)
                        )
                        .foregroundStyle(borderColor)
                )
        }
    }
}


// ============= used to write big text =================
struct TextTitle: View {
    let text: String
    let fontName: String
    let size: CGFloat
    let strokeWidth: CGFloat
    var color: Color = .white

    var body: some View {
        ZStack {
            Text(text).offset(x: -strokeWidth, y: 0)
            Text(text).offset(x: strokeWidth, y: 0)
            Text(text).offset(x: 0, y: -strokeWidth)
            Text(text).offset(x: 0, y: strokeWidth)

            Text(text)
                .foregroundColor(color)
        }
        .font(.custom(fontName, size: size))
        .foregroundColor(.black)
        .shadow(color: .black, radius: 0, x: 4, y: 6)
    }
}

