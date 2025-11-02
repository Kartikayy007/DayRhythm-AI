//
//  DarkLoginSheet.swift
//  DayRhythm AI
//
//  Created by kartikay on 30/10/25.
//

import SwiftUI

struct DarkLoginSheet: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var useOTP = false
    @State private var showOTPSheet = false
    @State private var showSignupSheet = false
    @State private var showPassword = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Log in")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.white)

                            Text("By logging in, you agree to our Terms of Use.")
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

                                Text("We will send you a one-time password")
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
                                    await viewModel.signIn()
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
                                    Text("Login")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "FF6B35"))
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.isLoading || viewModel.email.isEmpty || (!useOTP && viewModel.password.isEmpty))
                        .opacity(viewModel.email.isEmpty || (!useOTP && viewModel.password.isEmpty) ? 0.5 : 1.0)
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
                            Text("Don't have an account?")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))

                            Button(action: {
                                showSignupSheet = true
                            }) {
                                Text("Sign up")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.appPrimary)
                            }
                        }
                        .padding(.top, 20)

                        Text("For more information, please see our Privacy policy.")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
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
        .sheet(isPresented: $showSignupSheet) {
            DarkSignupSheet()
                .environmentObject(appState)
        }
        .onChange(of: viewModel.email) { _ in
            viewModel.clearError()
        }
    }
}

#Preview {
    DarkLoginSheet()
        .environmentObject(AppState.shared)
}
