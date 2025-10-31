//
//  SettingsView.swift
//  DayRhythm AI
//
//  Created by kartikay on 30/10/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var authViewModel = AuthenticationViewModel()

    @State private var showLoginSheet = false
    @State private var showSignupSheet = false
    @State private var showSignOutAlert = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Profile")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 20)

                        if !appState.isAuthenticated {
                            Text("Log in and start planning your next trip.")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.bottom, 8)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                    if appState.isAuthenticated, let user = appState.currentUser {
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "FF6B35") ?? .orange, Color(hex: "FF8C42") ?? .orange],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 72, height: 72)
                                    .overlay(
                                        Text(String(user.email.prefix(1)).uppercased())
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.white)
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.displayName ?? "User")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)

                                    Text(user.email)
                                        .font(.system(size: 15))
                                        .foregroundColor(.white.opacity(0.6))
                                }

                                Spacer()

                                Button(action: {}) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                        }
                    } else {
                        Button(action: {
                            showLoginSheet = true
                        }) {
                            HStack {
                                Text("Log in or sign up")
                                    .font(.system(size: 17, weight: .semibold))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }

                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Settings")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)

                        SettingsRowButton(icon: "bell", title: "Notifications")
                        SettingsRowButton(icon: "moon", title: "Dark Mode")
                        SettingsRowButton(icon: "globe", title: "Language")
                        SettingsRowButton(icon: "calendar", title: "First Day of Week")
                        SettingsRowButton(icon: "clock", title: "Time Format")
                    }

                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)

                    VStack(alignment: .leading, spacing: 0) {
                        if appState.isAuthenticated {
                            Text("Account")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 12)

                            SettingsRowButton(icon: "person.circle", title: "Personal information")
                            SettingsRowButton(icon: "lock", title: "Login & security")
                            SettingsRowButton(icon: "creditcard", title: "Payments & payouts")
                        }
                    }

                    if appState.isAuthenticated {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 1)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 24)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Support")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)

                        SettingsRowButton(icon: "questionmark.circle", title: "Get help")
                        SettingsRowButton(icon: "exclamationmark.bubble", title: "Give us feedback")
                    }

                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Legal")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)

                        SettingsRowButton(icon: "doc.text", title: "Terms of Service")
                        SettingsRowButton(icon: "hand.raised", title: "Privacy Policy")
                        SettingsRowButton(icon: "shield", title: "Open source licenses")
                    }

                    if appState.isAuthenticated {
                        Button(action: {
                            showSignOutAlert = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 18))
                                Text("Sign Out")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    }

                    Text("Version 1.0.0 (Build 1)")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.top, 32)
                        .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showLoginSheet) {
            DarkLoginSheet()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showSignupSheet) {
            DarkSignupSheet()
                .environmentObject(appState)
        }
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                Task {
                    await authViewModel.signOut()
                }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

struct SettingsRowButton: View {
    let icon: String
    let title: String

    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 17))
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState.shared)
}
