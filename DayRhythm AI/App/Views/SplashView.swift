//
//  SplashView.swift
//  DayRhythm AI
//
//  Created by kartikay on 03/11/25.
//

import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 24) {
                
                Image("LaunchLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .cornerRadius(28)
                    .shadow(color: Color.appPrimary.opacity(0.5), radius: 30, y: 10)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                
                VStack(spacing: 8) {
                    Text("DayRhythm AI")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Your Intelligent Day Planner")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                .opacity(textOpacity)
            }
        }
        .onAppear {
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            
            withAnimation(.easeIn(duration: 0.6).delay(0.3)) {
                textOpacity = 1.0
            }
        }
    }
}

#Preview {
    SplashView()
}
