//
//  NotificationSettingsView.swift
//  DayRhythm AI
//
//  Created by kartikay on 31/10/25.
//

import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = false
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @State private var showOpenSettingsAlert = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Text("Notifications")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 24) {
                        
                        statusCard

                        
                        if authorizationStatus == .authorized {
                            infoSection
                        } else if authorizationStatus == .denied {
                            deniedSection
                        }

                        Spacer()
                            .frame(height: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await checkNotificationStatus()
        }
        .alert("Open Settings", isPresented: $showOpenSettingsAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("To enable notifications, please allow notification permissions in Settings.")
        }
    }

    private var statusCard: some View {
        VStack(spacing: 16) {
            
            ZStack {
                Circle()
                    .fill(
                        authorizationStatus == .authorized
                            ? Color.appPrimary.opacity(0.2)
                            : Color.white.opacity(0.1)
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: authorizationStatus == .authorized ? "bell.badge.fill" : "bell.slash.fill")
                    .font(.system(size: 36))
                    .foregroundColor(
                        authorizationStatus == .authorized
                            ? Color.appPrimary
                            : .white.opacity(0.4)
                    )
            }

            
            VStack(spacing: 8) {
                Text(statusTitle)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                Text(statusDescription)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }

            
            if authorizationStatus != .authorized {
                Button(action: handleEnableNotifications) {
                    Text(authorizationStatus == .denied ? "Open Settings" : "Enable Notifications")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.appPrimary)
                        )
                }
                .padding(.top, 8)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            authorizationStatus == .authorized
                                ? Color.appPrimary.opacity(0.3)
                                : Color.white.opacity(0.08),
                            lineWidth: 1
                        )
                )
        )
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How It Works")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: 12) {
                InfoRow(
                    icon: "bell.badge",
                    title: "Task Reminders",
                    description: "Get notified before your tasks start"
                )

                InfoRow(
                    icon: "clock",
                    title: "Custom Timing",
                    description: "Choose when to receive notifications for each task"
                )

                InfoRow(
                    icon: "checkmark.circle",
                    title: "Stay on Track",
                    description: "Never miss an important task or meeting"
                )
            }
        }
    }

    private var deniedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Why Enable Notifications?")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: 12) {
                InfoRow(
                    icon: "exclamationmark.triangle",
                    title: "Permissions Required",
                    description: "Notification permissions are currently disabled. Enable them in Settings to receive task reminders."
                )
            }
        }
    }

    private var statusTitle: String {
        switch authorizationStatus {
        case .authorized:
            return "Notifications Enabled"
        case .denied:
            return "Notifications Disabled"
        case .notDetermined:
            return "Enable Notifications"
        case .provisional:
            return "Limited Notifications"
        case .ephemeral:
            return "Temporary Notifications"
        @unknown default:
            return "Notification Status Unknown"
        }
    }

    private var statusDescription: String {
        switch authorizationStatus {
        case .authorized:
            return "You'll receive reminders for your upcoming tasks"
        case .denied:
            return "Enable notifications in Settings to receive task reminders"
        case .notDetermined:
            return "Get reminded before your tasks start so you never miss anything important"
        case .provisional:
            return "You're receiving quiet notifications"
        case .ephemeral:
            return "You're receiving temporary notifications"
        @unknown default:
            return "Unable to determine notification status"
        }
    }

    private func checkNotificationStatus() async {
        authorizationStatus = await NotificationService.shared.checkAuthorizationStatus()
        notificationsEnabled = authorizationStatus == .authorized
    }

    private func handleEnableNotifications() {
        if authorizationStatus == .denied {
            showOpenSettingsAlert = true
        } else {
            Task {
                let granted = await NotificationService.shared.requestAuthorization()
                await checkNotificationStatus()
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.appPrimary.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color.appPrimary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(3)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
        )
    }
}

#Preview {
    NotificationSettingsView()
}
