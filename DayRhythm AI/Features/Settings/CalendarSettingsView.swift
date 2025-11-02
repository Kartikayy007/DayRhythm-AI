//
//  CalendarSettingsView.swift
//  DayRhythm AI
//
//  Created by kartikay on 02/11/25.
//

import SwiftUI
import EventKit

struct CalendarSettingsView: View {
    @StateObject private var eventKitService = EventKitService.shared
    @State private var isRequestingAccess = false
    @State private var showingAccessDeniedAlert = false
    @AppStorage("calendarSyncEnabled") private var calendarSyncEnabled: Bool = false

    private var isCalendarAuthorized: Bool {
        if #available(iOS 17.0, *) {
            return eventKitService.authorizationStatus == .authorized ||
                   eventKitService.authorizationStatus == EKAuthorizationStatus.fullAccess
        } else {
            return eventKitService.authorizationStatus == .authorized
        }
    }

    var body: some View {
        List {
            
            Section {
                Toggle(isOn: Binding(
                    get: { calendarSyncEnabled && isCalendarAuthorized },
                    set: { newValue in
                        if newValue && !isCalendarAuthorized {
                            
                            requestAccess()
                        } else {
                            calendarSyncEnabled = newValue
                            if newValue {
                                
                                NotificationCenter.default.post(name: .calendarSyncRequested, object: nil)
                            }
                        }
                    }
                )) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sync with Calendar")
                            .font(.system(size: 17))
                            .foregroundColor(.primary)

                        Text(calendarSyncEnabled && isCalendarAuthorized ? "Events sync automatically" : "Enable to sync with iOS Calendar")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                .tint(Color.appPrimary)
            }

            
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Calendar Access")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)

                        Text(statusDescription)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if eventKitService.authorizationStatus == .notDetermined {
                        Button(action: requestAccess) {
                            if isRequestingAccess {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Text("Tap on Toggle button above")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.appPrimary)
                                    .cornerRadius(20)
                            }
                        }
                        .disabled(isRequestingAccess)
                    } else if eventKitService.authorizationStatus == .denied ||
                             eventKitService.authorizationStatus == .restricted {
                        Button(action: openSettings) {
                            Text("Settings")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.appPrimary)
                        }
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 20))
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("PERMISSIONS")
            } footer: {
                Text("DayRhythm AI needs calendar access to sync your events and tasks.")
            }

            
            if isCalendarAuthorized {
                Section {
                    if eventKitService.availableCalendars.isEmpty {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading calendars...")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    } else {
                        ForEach(eventKitService.availableCalendars, id: \.calendarIdentifier) { calendar in
                            CalendarRow(
                                calendar: calendar,
                                isSelected: eventKitService.selectedCalendars.contains(calendar.calendarIdentifier),
                                onToggle: {
                                    eventKitService.toggleCalendarSelection(calendar.calendarIdentifier)
                                }
                            )
                        }
                    }
                } header: {
                    Text("CALENDARS TO SYNC")
                } footer: {
                    Text("Select which calendars to sync with DayRhythm AI. Events from selected calendars will appear in your daily view automatically.")
                }
            }
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.large)
        .alert("Calendar Access Denied", isPresented: $showingAccessDeniedAlert) {
            Button("Open Settings", action: openSettings)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable calendar access in Settings to sync your events.")
        }
        .task {
            await loadCalendars()
            
            if calendarSyncEnabled && isCalendarAuthorized {
                NotificationCenter.default.post(name: .calendarSyncRequested, object: nil)
            }
        }
    }

    private var statusDescription: String {
        if #available(iOS 17.0, *) {
            switch eventKitService.authorizationStatus {
            case .notDetermined:
                return "Not enabled"
            case .restricted:
                return "Restricted by system"
            case .denied:
                return "Access denied"
            case .authorized:
                return "Access granted"
            case .fullAccess:
                return "Access granted"
            case .writeOnly:
                return "Write-only access"
            @unknown default:
                return "Unknown"
            }
        } else {
            switch eventKitService.authorizationStatus {
            case .notDetermined:
                return "Not enabled"
            case .restricted:
                return "Restricted by system"
            case .denied:
                return "Access denied"
            case .authorized:
                return "Access granted"
            @unknown default:
                return "Unknown"
            }
        }
    }

    private func requestAccess() {
        isRequestingAccess = true

        Task {
            let granted = await eventKitService.requestCalendarAccess()

            await MainActor.run {
                isRequestingAccess = false

                if granted {
                    
                    calendarSyncEnabled = true
                    
                    NotificationCenter.default.post(name: .calendarSyncRequested, object: nil)
                } else {
                    showingAccessDeniedAlert = true
                }
            }
        }
    }

    private func loadCalendars() async {
        await eventKitService.loadCalendars()
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}



struct CalendarRow: View {
    let calendar: EKCalendar
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            
            Circle()
                .fill(Color(cgColor: calendar.cgColor))
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(calendar.title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)

                if let source = calendar.source?.title {
                    Text(source)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { isSelected },
                set: { _ in onToggle() }
            ))
        }
        .padding(.vertical, 4)
    }
}



extension Notification.Name {
    static let calendarSyncRequested = Notification.Name("calendarSyncRequested")
    static let calendarDataChanged = Notification.Name("calendarDataChanged")
}

#Preview {
    NavigationView {
        CalendarSettingsView()
    }
}