//
//  SettingsView.swift
//  DayRhythm AI
//
//  Settings screen for app preferences and configuration
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Header
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)

                // Settings content placeholder
                ScrollView {
                    VStack(spacing: 15) {
                        // Placeholder settings items
                        SettingsRow(icon: "bell", title: "Notifications", value: "On")
                        SettingsRow(icon: "moon", title: "Dark Mode", value: "Auto")
                        SettingsRow(icon: "globe", title: "Language", value: "English")
                        SettingsRow(icon: "calendar", title: "First Day of Week", value: "Monday")
                        SettingsRow(icon: "clock", title: "Time Format", value: "24h")
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
        }
    }
}

// Settings row component
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