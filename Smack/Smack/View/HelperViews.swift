//
//  HelperViews.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 27/05/2026.
//
import SwiftUI

struct ButtonView: View {
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        ZStack {
            // Shadow rectangle (slightly offset)
            RoundedRectangle(cornerRadius: 20)
                .fill(.black)
                .frame(width: width, height: height)
                .offset(x: 6, y: 6)
            
            // Main white rectangle on top
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .frame(width: width, height: height)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.black, lineWidth: 4)
                )
        }
    }
}

