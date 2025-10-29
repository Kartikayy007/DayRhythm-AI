//
//  AuthenticationGateView.swift
//  DayRhythm AI
//
//  Created by kartikay on 29/10/25.
//

import SwiftUI

struct AuthenticationGateView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @EnvironmentObject var appState: AppState

    @State private var selectedTab = 0 

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                
                VStack(spacing: 12) {
                    Text("Welcome to")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))

                    Text("DayRhythm AI")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)

                    Text("Your intelligent daily planner")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.top, 60)
                .padding(.bottom, 40)

                
                HStack(spacing: 0) {
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTab = 0
                        }
                    }) {
                        VStack(spacing: 8) {
                            Text("Login")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(selectedTab == 0 ? .white : .white.opacity(0.5))

                            Rectangle()
                                .fill(selectedTab == 0 ? Color.appPrimary : Color.clear)
                                .frame(height: 3)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTab = 1
                        }
                    }) {
                        VStack(spacing: 8) {
                            Text("Sign Up")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(selectedTab == 1 ? .white : .white.opacity(0.5))

                            Rectangle()
                                .fill(selectedTab == 1 ? Color.appPrimary : Color.clear)
                                .frame(height: 3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 32)

                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        if selectedTab == 0 {
                            
                            loginContent
                        } else {
                            
                            signupContent
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    
    private var loginContent: some View {
        VStack(spacing: 24) {
            
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
        }
    }

    
    private var signupContent: some View {
        VStack(spacing: 24) {
            
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
    AuthenticationGateView()
        .environmentObject(AppState.shared)
}
