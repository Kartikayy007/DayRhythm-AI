//
//  AuthenticationPromptView.swift
//  DayRhythm AI
//
//  Created by kartikay on 30/10/25.
//

import SwiftUI

struct AuthenticationPromptView: View {
    let title: String
    let message: String
    let icon: String

    @State private var showLoginSheet = false
    @State private var showSignupSheet = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 64))
                    .foregroundColor(Color.appPrimary.opacity(0.6))

                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 12) {
                Button(action: {
                    showLoginSheet = true
                }) {
                    Text("Log In")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "FF6B35"))
                        .cornerRadius(12)
                }

                Button(action: {
                    showSignupSheet = true
                }) {
                    Text("Sign Up")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .sheet(isPresented: $showLoginSheet) {
            DarkLoginSheet()
        }
        .sheet(isPresented: $showSignupSheet) {
            DarkSignupSheet()
        }
    }
}

#Preview {
    AuthenticationPromptView(
        title: "Sign in to use AI features",
        message: "Create an account or log in to unlock AI-powered task planning and insights",
        icon: "sparkles"
    )
}
