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

            VStack(spacing: 20) {
                
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)

                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        VStack(spacing: 12) {
                            if appState.isAuthenticated, let user = appState.currentUser {
                                
                                VStack(spacing: 12) {
                                    
                                    HStack(spacing: 16) {
                                        
                                        Circle()
                                            .fill(Color.appPrimary.opacity(0.3))
                                            .frame(width: 56, height: 56)
                                            .overlay(
                                                Text(String(user.email.prefix(1)).uppercased())
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(.white)
                                            )

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(user.displayName ?? "User")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(.white)

                                            Text(user.email)
                                                .font(.system(size: 14))
                                                .foregroundColor(.white.opacity(0.6))
                                        }

                                        Spacer()
                                    }
                                    .padding(16)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)

                                    
                                    Button(action: {
                                        showSignOutAlert = true
                                    }) {
                                        HStack {
                                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                                .font(.system(size: 18))
                                            Text("Sign Out")
                                                .font(.system(size: 16, weight: .medium))
                                        }
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(10)
                                    }
                                }
                            } else {
                                
                                VStack(spacing: 12) {
                                    Text("Sign in to sync your schedule")
                                        .font(.system(size: 15))
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.bottom, 4)

                                    
                                    Button(action: {
                                        showLoginSheet = true
                                    }) {
                                        HStack {
                                            Image(systemName: "person.circle.fill")
                                                .font(.system(size: 18))
                                            Text("Login")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color.appPrimary)
                                        .cornerRadius(10)
                                    }

                                    
                                    Button(action: {
                                        showSignupSheet = true
                                    }) {
                                        HStack {
                                            Image(systemName: "person.badge.plus")
                                                .font(.system(size: 18))
                                            Text("Sign Up")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)

                        
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 1)
                            .padding(.horizontal)
                            .padding(.vertical, 4)

                        
                        VStack(spacing: 15) {
                            SettingsRow(icon: "bell", title: "Notifications", value: "On")
                            SettingsRow(icon: "moon", title: "Dark Mode", value: "Auto")
                            SettingsRow(icon: "globe", title: "Language", value: "English")
                            SettingsRow(icon: "calendar", title: "First Day of Week", value: "Monday")
                            SettingsRow(icon: "clock", title: "Time Format", value: "24h")
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 10)
                }

                Spacer()
            }
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginSheet()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showSignupSheet) {
            SignupSheet()
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


struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 30)

            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)

            Spacer()

            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

#Preview {
    SettingsView()
}