//
//  LoginSheet.swift
//  DayRhythm AI
//
//  Created by kartikay on 29/10/25.
//

import SwiftUI

struct LoginSheet: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var showSignupSheet = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()

                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Welcome Back")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)

                            Text("Sign in to sync your schedule")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)

                        VStack(spacing: 16) {
                            AuthTextField(
                                icon: "envelope",
                                placeholder: "Email",
                                text: $viewModel.email
                            )

                            AuthTextField(
                                icon: "lock",
                                placeholder: "Password",
                                text: $viewModel.password,
                                isSecure: true
                            )
                        }

                        if let errorMessage = viewModel.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14))
                                Text(errorMessage)
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(.red.opacity(0.8))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }

                        AuthButton(
                            title: "Login",
                            style: .primary,
                            isLoading: viewModel.isLoading,
                            action: {
                                Task {
                                    await viewModel.signIn()
                                    if appState.isAuthenticated {
                                        dismiss()
                                    }
                                }
                            }
                        )
                        .padding(.top, 8)

                        HStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 1)

                            Text("or")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 12)

                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 1)
                        }
                        .padding(.vertical, 8)

                        
                        VStack(spacing: 12) {
                            AuthButton(
                                title: "Continue with Apple",
                                icon: "apple.logo",
                                style: .apple,
                                isLoading: false,
                                action: {
                                    
                                    viewModel.errorMessage = "Apple Sign In coming soon"
                                }
                            )

                            AuthButton(
                                title: "Continue with Google",
                                icon: "globe",
                                style: .google,
                                isLoading: false,
                                action: {
                                    
                                    viewModel.errorMessage = "Google Sign In coming soon"
                                }
                            )
                        }

                        
                        HStack {
                            Text("Don't have an account?")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.6))

                            Button(action: {
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showSignupSheet = true
                                }
                            }) {
                                Text("Sign up")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.appPrimary)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .sheet(isPresented: $showSignupSheet) {
            SignupSheet()
                .environmentObject(appState)
        }
        .onChange(of: viewModel.email) { _ in
            viewModel.clearError()
        }
        .onChange(of: viewModel.password) { _ in
            viewModel.clearError()
        }
    }
}

#Preview {
    LoginSheet()
        .environmentObject(AppState.shared)
}
