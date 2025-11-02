//
//  EventKitService.swift
//  DayRhythm AI
//
//  Created by kartikay on 02/11/25.
//

import EventKit
import SwiftUI
import Combine

class EventKitService: ObservableObject {
    static let shared = EventKitService()

    private let eventStore = EKEventStore()
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var availableCalendars: [EKCalendar] = []
    @Published var selectedCalendars: Set<String> = []

    private init() {
        checkAuthorizationStatus()
        loadSavedCalendarSelection()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(eventStoreChanged),
            name: .EKEventStoreChanged,
            object: eventStore
        )
    }

    @objc private func eventStoreChanged(notification: NSNotification) {
        
        
        NotificationCenter.default.post(name: .calendarDataChanged, object: nil)
    }

    

    
    func checkAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }

    
    func requestCalendarAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            do {
                let granted = try await eventStore.requestFullAccessToEvents()
                await MainActor.run {
                    authorizationStatus = granted ? EKAuthorizationStatus.fullAccess : .denied
                }
                if granted {
                    await loadCalendars()
                }
                return granted
            } catch {
                
                return false
            }
        } else {
            
            return await withCheckedContinuation { continuation in
                eventStore.requestAccess(to: .event) { [weak self] granted, error in
                    Task { @MainActor in
                        self?.authorizationStatus = granted ? .authorized : .denied
                        if granted {
                            await self?.loadCalendars()
                        }
                    }
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    

    
    @MainActor
    func loadCalendars() async {
        if #available(iOS 17.0, *) {
            guard authorizationStatus == .authorized || authorizationStatus == EKAuthorizationStatus.fullAccess else { return }
        } else {
            guard authorizationStatus == .authorized else { return }
        }

        let calendars = eventStore.calendars(for: .event)
        availableCalendars = calendars.filter { $0.allowsContentModifications }

        
        if selectedCalendars.isEmpty, let defaultCalendar = eventStore.defaultCalendarForNewEvents {
            selectedCalendars.insert(defaultCalendar.calendarIdentifier)
            saveCalendarSelection()
        }
    }

    
    func toggleCalendarSelection(_ calendarId: String) {
        if selectedCalendars.contains(calendarId) {
            selectedCalendars.remove(calendarId)
        } else {
            selectedCalendars.insert(calendarId)
        }
        saveCalendarSelection()
    }

    
    private func saveCalendarSelection() {
        UserDefaults.standard.set(Array(selectedCalendars), forKey: "SelectedCalendarIds")
    }

    
    private func loadSavedCalendarSelection() {
        if let saved = UserDefaults.standard.array(forKey: "SelectedCalendarIds") as? [String] {
            selectedCalendars = Set(saved)
        }
    }

    

    
    func fetchEvents(from startDate: Date, to endDate: Date) async throws -> [EKEvent] {
        if #available(iOS 17.0, *) {
            guard authorizationStatus == .authorized || authorizationStatus == EKAuthorizationStatus.fullAccess else {
                throw EventKitError.notAuthorized
            }
        } else {
            guard authorizationStatus == .authorized else {
                throw EventKitError.notAuthorized
            }
        }

        let selectedCalendarObjects = availableCalendars.filter {
            selectedCalendars.contains($0.calendarIdentifier)
        }

        guard !selectedCalendarObjects.isEmpty else {
            return []
        }

        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: selectedCalendarObjects
        )

        let events = eventStore.events(matching: predicate)
        return events
    }

    

    
    func createEvent(from dayEvent: DayEvent, in calendarId: String) async throws -> String {
        if #available(iOS 17.0, *) {
            guard authorizationStatus == .authorized || authorizationStatus == EKAuthorizationStatus.fullAccess else {
                throw EventKitError.notAuthorized
            }
        } else {
            guard authorizationStatus == .authorized else {
                throw EventKitError.notAuthorized
            }
        }

        guard let calendar = availableCalendars.first(where: { $0.calendarIdentifier == calendarId }) else {
            throw EventKitError.calendarNotFound
        }

        let ekEvent = EKEvent(eventStore: eventStore)

        
        ekEvent.title = "\(dayEvent.emoji) \(dayEvent.title)"
        ekEvent.notes = dayEvent.description.isEmpty ? nil : dayEvent.description
        ekEvent.calendar = calendar

        
        let date = dateFromString(dayEvent.dateString) ?? Date()
        ekEvent.startDate = dateByAddingHours(dayEvent.startHour, to: date)
        ekEvent.endDate = dateByAddingHours(dayEvent.endHour, to: date)

        
        if dayEvent.notificationSettings.enabled {
            for minutesBefore in dayEvent.notificationSettings.minutesBefore {
                let alarm = EKAlarm(relativeOffset: -Double(minutesBefore * 60))
                ekEvent.addAlarm(alarm)
            }
        }

        
        try eventStore.save(ekEvent, span: .thisEvent, commit: true)

        return ekEvent.eventIdentifier
    }

    

    
    func updateEvent(with identifier: String, from dayEvent: DayEvent) async throws {
        if #available(iOS 17.0, *) {
            guard authorizationStatus == .authorized || authorizationStatus == EKAuthorizationStatus.fullAccess else {
                throw EventKitError.notAuthorized
            }
        } else {
            guard authorizationStatus == .authorized else {
                throw EventKitError.notAuthorized
            }
        }

        guard let ekEvent = eventStore.event(withIdentifier: identifier) else {
            throw EventKitError.eventNotFound
        }

        
        ekEvent.title = "\(dayEvent.emoji) \(dayEvent.title)"
        ekEvent.notes = dayEvent.description.isEmpty ? nil : dayEvent.description

        
        let date = dateFromString(dayEvent.dateString) ?? Date()
        ekEvent.startDate = dateByAddingHours(dayEvent.startHour, to: date)
        ekEvent.endDate = dateByAddingHours(dayEvent.endHour, to: date)

        
        ekEvent.alarms?.forEach { ekEvent.removeAlarm($0) }
        if dayEvent.notificationSettings.enabled {
            for minutesBefore in dayEvent.notificationSettings.minutesBefore {
                let alarm = EKAlarm(relativeOffset: -Double(minutesBefore * 60))
                ekEvent.addAlarm(alarm)
            }
        }

        try eventStore.save(ekEvent, span: .thisEvent, commit: true)
    }

    

    
    func deleteEvent(with identifier: String) async throws {
        if #available(iOS 17.0, *) {
            guard authorizationStatus == .authorized || authorizationStatus == EKAuthorizationStatus.fullAccess else {
                throw EventKitError.notAuthorized
            }
        } else {
            guard authorizationStatus == .authorized else {
                throw EventKitError.notAuthorized
            }
        }

        guard let ekEvent = eventStore.event(withIdentifier: identifier) else {
            throw EventKitError.eventNotFound
        }

        try eventStore.remove(ekEvent, span: .thisEvent, commit: true)
    }

    

    
    func convertToDayEvent(_ ekEvent: EKEvent) -> DayEvent? {
        guard let startDate = ekEvent.startDate,
              let endDate = ekEvent.endDate else { return nil }

        let calendar = Calendar.current
        let startHour = Double(calendar.component(.hour, from: startDate)) +
                       Double(calendar.component(.minute, from: startDate)) / 60.0
        let endHour = Double(calendar.component(.hour, from: endDate)) +
                     Double(calendar.component(.minute, from: endDate)) / 60.0

        
        let (emoji, cleanTitle) = extractEmojiFromTitle(ekEvent.title ?? "")

        
        let notificationSettings = createNotificationSettings(from: ekEvent.alarms ?? [])

        
        let calendarColor = Color(cgColor: ekEvent.calendar.cgColor)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: startDate)

        return DayEvent(
            title: cleanTitle,
            startHour: startHour,
            endHour: endHour,
            color: calendarColor,
            category: "Calendar",
            emoji: emoji,
            description: ekEvent.notes ?? "",
            participants: [], 
            isCompleted: false,
            notificationSettings: notificationSettings,
            cloudId: nil,
            syncStatus: .local,
            lastModified: ekEvent.lastModifiedDate,
            dateString: dateString,
            ekEventIdentifier: ekEvent.eventIdentifier,
            ekCalendarIdentifier: ekEvent.calendar.calendarIdentifier,
            isFromCalendar: true
        )
    }

    

    private func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.date(from: dateString)
    }

    private func dateByAddingHours(_ hours: Double, to date: Date) -> Date {
        let totalMinutes = Int(hours * 60)
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .minute, value: totalMinutes, to: startOfDay) ?? date
    }

    private func extractEmojiFromTitle(_ title: String) -> (emoji: String, title: String) {
        
        if let firstChar = title.first, firstChar.isEmoji {
            let emoji = String(firstChar)
            let cleanTitle = String(title.dropFirst()).trimmingCharacters(in: .whitespaces)
            return (emoji, cleanTitle)
        }
        return ("📅", title)
    }

    private func createNotificationSettings(from alarms: [EKAlarm]) -> NotificationSettings {
        guard !alarms.isEmpty else {
            return .disabled
        }

        let minutesBefore = alarms.compactMap { alarm -> Int? in
            guard alarm.relativeOffset < 0 else { return nil }
            return Int(-alarm.relativeOffset / 60)
        }.sorted()

        return NotificationSettings(
            enabled: true,
            minutesBefore: minutesBefore,
            notificationIds: []
        )
    }
}



enum EventKitError: LocalizedError {
    case notAuthorized
    case calendarNotFound
    case eventNotFound
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Calendar access not authorized. Please enable in Settings."
        case .calendarNotFound:
            return "Selected calendar not found."
        case .eventNotFound:
            return "Event not found in calendar."
        case .saveFailed:
            return "Failed to save event to calendar."
        }
    }
}



extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value >= 0x1F600 || scalar.properties.isEmojiPresentation)
    }
}

