//
//  DarkSignupSheet.swift
//  DayRhythm AI
//
//  Created by kartikay on 30/10/25.
//

import SwiftUI

struct DarkSignupSheet: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var useOTP = false
    @State private var showOTPSheet = false
    @State private var showLoginSheet = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sign up")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.white)

                            Text("Create your account to start planning.")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 24)
                        .padding(.bottom, 16)

                        if !useOTP {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Email")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))

                                TextField("Your email", text: $viewModel.email)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                            }

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Password")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))

                                HStack(spacing: 12) {
                                    if showPassword {
                                        TextField("Your password", text: $viewModel.password)
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                            .autocapitalization(.none)
                                            .textContentType(.password)
                                    } else {
                                        SecureField("Your password", text: $viewModel.password)
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                            .autocapitalization(.none)
                                            .textContentType(.password)
                                    }

                                    Button(action: {
                                        showPassword.toggle()
                                    }) {
                                        Image(systemName: showPassword ? "eye" : "eye.slash")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white.opacity(0.6))
                                            .frame(width: 24, height: 24)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                            }

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Confirm Password")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))

                                HStack(spacing: 12) {
                                    if showConfirmPassword {
                                        TextField("Confirm your password", text: $viewModel.confirmPassword)
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                            .autocapitalization(.none)
                                            .textContentType(.password)
                                    } else {
                                        SecureField("Confirm your password", text: $viewModel.confirmPassword)
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                            .autocapitalization(.none)
                                            .textContentType(.password)
                                    }

                                    Button(action: {
                                        showConfirmPassword.toggle()
                                    }) {
                                        Image(systemName: showConfirmPassword ? "eye" : "eye.slash")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white.opacity(0.6))
                                            .frame(width: 24, height: 24)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
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
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Email")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))

                                TextField("Your email", text: $viewModel.email)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)

                                Text("We will send you a one-time password to verify your email")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                    .padding(.top, 4)
                            }
                        }

                        Button(action: {
                            withAnimation {
                                useOTP.toggle()
                            }
                        }) {
                            Text(useOTP ? "Use password instead" : "Use one-time password instead")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.appPrimary)
                        }
                        .padding(.top, -8)

                        if let errorMessage = viewModel.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 14))
                                Text(errorMessage)
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.15))
                            .cornerRadius(10)
                        }

                        Button(action: {
                            Task {
                                if useOTP {
                                    await viewModel.sendOTP()
                                    if viewModel.otpSent {
                                        showOTPSheet = true
                                    }
                                } else {
                                    await viewModel.signUp()
                                    if appState.isAuthenticated {
                                        dismiss()
                                    }
                                }
                            }
                        }) {
                            Group {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Create Account")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "FF6B35") ?? .orange, Color(hex: "FF8C42") ?? .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.isLoading || viewModel.email.isEmpty || (!useOTP && (viewModel.password.isEmpty || viewModel.confirmPassword.isEmpty)))
                        .opacity(viewModel.email.isEmpty || (!useOTP && (viewModel.password.isEmpty || viewModel.confirmPassword.isEmpty)) ? 0.5 : 1.0)
                        .padding(.top, 8)

                        HStack(spacing: 12) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                            Text("Or")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.vertical, 8)

                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))

                            Button(action: {
                                showLoginSheet = true
                            }) {
                                Text("Log in")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.appPrimary)
                            }
                        }
                        .padding(.top, 20)

                        Text("By creating an account, you agree to our Terms of Use and Privacy policy.")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 12)
                            .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showOTPSheet) {
            OTPVerificationSheet(
                email: viewModel.email,
                onVerified: {
                    dismiss()
                }
            )
        }
        .sheet(isPresented: $showLoginSheet) {
            DarkLoginSheet()
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
    DarkSignupSheet()
        .environmentObject(AppState.shared)
}
