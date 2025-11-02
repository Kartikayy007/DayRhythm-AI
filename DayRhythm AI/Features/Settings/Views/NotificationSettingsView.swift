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

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Enable Notifications")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.white)

                            Text("Get notified before your tasks start so you never miss anything important")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.6))
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { authorizationStatus == .authorized },
                            set: { newValue in
                                if newValue {
                                    handleEnableNotifications()
                                } else {
                                    
                                    showOpenSettingsAlert = true
                                }
                            }
                        ))
                        .labelsHidden()
                        .tint(Color.appPrimary)
                    }
                    .padding(20)

                    if authorizationStatus == .denied {
                        Text("Notification permissions are disabled. Please enable them in Settings.")
                            .font(.system(size: 13))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                    }
                }
                .padding(.top, 24)

                Spacer()
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

#Preview {
    NotificationSettingsView()
}
