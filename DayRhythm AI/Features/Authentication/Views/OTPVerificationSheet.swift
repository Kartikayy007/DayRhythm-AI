//
//  OTPVerificationSheet.swift
//  DayRhythm AI
//
//  Created by kartikay on 30/10/25.
//

import SwiftUI

struct OTPVerificationSheet: View {
    let email: String
    let onVerified: () -> Void

    @StateObject private var viewModel = AuthenticationViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var otpCode = ""
    @FocusState private var isOTPFocused: Bool

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    VStack(spacing: 16) {
                        Image(systemName: "envelope.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(Color.appPrimary)

                        Text("Enter Verification Code")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("We sent a code to")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)

                        Text(email)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 24)

                    HStack(spacing: 12) {
                        ForEach(0..<6, id: \.self) { index in
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 48, height: 56)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                otpCode.count == index ? Color.appPrimary : Color.clear,
                                                lineWidth: 2
                                            )
                                    )

                                if index < otpCode.count {
                                    Text(String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: index)]))
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    TextField("", text: $otpCode)
                        .keyboardType(.numberPad)
                        .focused($isOTPFocused)
                        .opacity(0)
                        .frame(height: 0)
                        .onChange(of: otpCode) { newValue in
                            if newValue.count > 6 {
                                otpCode = String(newValue.prefix(6))
                            }
                            if newValue.count == 6 {
                                Task {
                                    await verifyOTP()
                                }
                            }
                        }

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
                        .background(Color.red.opacity(0.15))
                        .cornerRadius(10)
                    }

                    Button(action: {
                        Task {
                            await viewModel.sendOTP()
                        }
                    }) {
                        HStack(spacing: 6) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.appPrimary))
                                    .scaleEffect(0.8)
                            }
                            Text(viewModel.isLoading ? "Sending..." : "Resend Code")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color.appPrimary)
                        }
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.top, 16)

                    Spacer()

                    Button(action: {
                        Task {
                            await verifyOTP()
                        }
                    }) {
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Verify")
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
                    .disabled(otpCode.count != 6 || viewModel.isLoading)
                    .opacity(otpCode.count != 6 ? 0.5 : 1.0)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
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
        .onAppear {
            isOTPFocused = true
            viewModel.email = email
        }
    }

    private func verifyOTP() async {
        await viewModel.verifyOTP(code: otpCode)
        if appState.isAuthenticated {
            onVerified()
        }
    }
}

#Preview {
    OTPVerificationSheet(email: "user@example.com", onVerified: {})
        .environmentObject(AppState.shared)
}
