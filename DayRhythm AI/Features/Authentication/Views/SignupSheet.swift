//
//  SignupSheet.swift
//  DayRhythm AI
//
//  Created by kartikay on 29/10/25.
//

import SwiftUI

struct SignupSheet: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var showLoginSheet = false

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
                            Text("Create Account")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)

                            Text("Sign up to sync across all your devices")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
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

                            AuthTextField(
                                icon: "lock.fill",
                                placeholder: "Confirm Password",
                                text: $viewModel.confirmPassword,
                                isSecure: true
                            )
                        }

                        
                        if !viewModel.password.isEmpty {
                            HStack(spacing: 8) {
                                ForEach(0..<4) { index in
                                    Rectangle()
                                        .fill(passwordStrengthColor(for: index))
                                        .frame(height: 3)
                                        .cornerRadius(1.5)
                                }
                            }
                            .padding(.horizontal, 4)

                            Text(passwordStrengthText)
                                .font(.system(size: 13))
                                .foregroundColor(passwordStrengthColor(for: 0))
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
                            title: "Create Account",
                            style: .primary,
                            isLoading: viewModel.isLoading,
                            action: {
                                Task {
                                    await viewModel.signUp()
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
                            Text("Already have an account?")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.6))

                            Button(action: {
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showLoginSheet = true
                                }
                            }) {
                                Text("Login")
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
        .sheet(isPresented: $showLoginSheet) {
            LoginSheet()
                .environmentObject(appState)
        }
        .onChange(of: viewModel.email) { _ in
            viewModel.clearError()
        }
        .onChange(of: viewModel.password) { _ in
            viewModel.clearError()
        }
        .onChange(of: viewModel.confirmPassword) { _ in
            viewModel.clearError()
        }
    }

    

    private var passwordStrength: Int {
        let password = viewModel.password
        var strength = 0

        if password.count >= 8 { strength += 1 }
        if password.count >= 12 { strength += 1 }
        if password.range(of: "[A-Z]", options: .regularExpression) != nil { strength += 1 }
        if password.range(of: "[0-9]", options: .regularExpression) != nil { strength += 1 }
        if password.range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil { strength += 1 }

        return min(strength, 4)
    }

    private func passwordStrengthColor(for index: Int) -> Color {
        let strength = passwordStrength

        if index >= strength {
            return Color.white.opacity(0.2)
        }

        switch strength {
        case 1:
            return .red
        case 2:
            return .orange
        case 3:
            return .yellow
        case 4:
            return .green
        default:
            return Color.white.opacity(0.2)
        }
    }

    private var passwordStrengthText: String {
        switch passwordStrength {
        case 1:
            return "Weak password"
        case 2:
            return "Fair password"
        case 3:
            return "Good password"
        case 4:
            return "Strong password"
        default:
            return ""
        }
    }
}

#Preview {
    SignupSheet()
        .environmentObject(AppState.shared)
}
