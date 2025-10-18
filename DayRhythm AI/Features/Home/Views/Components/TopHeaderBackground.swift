//
//  TopHeaderBackground.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI

struct TopHeaderBackground: ViewModifier {
    let cornerRadius: CGFloat
    let verticalExtension: CGFloat
    let verticalOffset: CGFloat
    
    init(
        cornerRadius: CGFloat = 40,
        verticalExtension: CGFloat = 60,
        verticalOffset: CGFloat = -60
    ) {
        self.cornerRadius = cornerRadius
        self.verticalExtension = verticalExtension
        self.verticalOffset = verticalOffset
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.appPrimary
                        .cornerRadius(cornerRadius, corners: [.bottomLeft, .bottomRight])
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height + verticalExtension
                        )
                        .offset(y: verticalOffset)
                }
            )
    }
}


extension View {
    
    func topHeaderBackground(
        cornerRadius: CGFloat = 40,
        verticalExtension: CGFloat = 60,
        verticalOffset: CGFloat = -60
    ) -> some View {
        modifier(TopHeaderBackground(
            cornerRadius: cornerRadius,
            verticalExtension: verticalExtension,
            verticalOffset: verticalOffset
        ))
    }
}
