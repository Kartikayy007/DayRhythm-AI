//
//  NotificationService.swift
//  DayRhythm AI
//
//  Created by kartikay on 31/10/25.
//

import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Permission Management

    /// Request notification permissions from the user
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            return granted
        } catch {
            
            return false
        }
    }

    /// Check current notification authorization status
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Notification Scheduling

    /// Schedule a notification for a task
    /// - Parameters:
    ///   - event: The DayEvent to create notification for
    ///   - date: The date of the event
    ///   - minutesBefore: How many minutes before the event to trigger notification
    /// - Returns: The notification identifier if successful, nil otherwise
    @discardableResult
    func scheduleNotification(
        for event: DayEvent,
        on date: Date,
        minutesBefore: Int
    ) async -> String? {
        // Check authorization first
        let status = await checkAuthorizationStatus()
        guard status == .authorized else {
            
            return nil
        }

        // FIXED: Proper date calculation using Calendar
        let calendar = Calendar.current

        // Get year, month, day from the selected date
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)

        // Calculate hour and minute from startHour (e.g., 14.5 = 2:30 PM)
        let totalMinutes = Int(event.startHour * 60)
        let hour = totalMinutes / 60
        let minute = totalMinutes % 60

        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = 0

        // Create the event start date
        guard let eventStartDate = calendar.date(from: dateComponents) else {
            
            return nil
        }

        // Subtract minutesBefore to get notification time
        guard let notificationDate = calendar.date(byAdding: .minute, value: -minutesBefore, to: eventStartDate) else {
            
            return nil
        }

        // Don't schedule if notification time is in the past (with 5 second buffer)
        let now = Date()
        guard notificationDate.timeIntervalSince(now) > 5 else {
            
            return nil
        }

        

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = event.emoji + " " + event.title

        if minutesBefore == 0 {
            content.body = "Your task is starting now"
        } else {
            content.body = "Starting in \(minutesBefore) minute\(minutesBefore == 1 ? "" : "s")"
        }

        if !event.description.isEmpty {
            content.subtitle = event.description
        }

        content.sound = .default
        content.badge = 1

        // Add event ID to userInfo for later reference
        content.userInfo = ["eventId": event.id.uuidString]

        // Create date components for trigger
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: notificationDate
        )

        // Create trigger
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        // Create unique identifier
        let identifier = "\(event.id.uuidString)-\(minutesBefore)"

        // Create request
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        // Schedule notification
        do {
            try await notificationCenter.add(request)
            
            
            
            
            
            return identifier
        } catch {
            
            
            
            return nil
        }
    }

    /// Schedule multiple notifications for a task (e.g., 15 min before, 5 min before)
    /// - Parameters:
    ///   - event: The DayEvent to create notifications for
    ///   - date: The date of the event
    ///   - minutesBeforeOptions: Array of minutes before event to trigger notifications
    /// - Returns: Array of notification identifiers
    func scheduleNotifications(
        for event: DayEvent,
        on date: Date,
        minutesBeforeOptions: [Int]
    ) async -> [String] {
        
        var identifiers: [String] = []

        for minutes in minutesBeforeOptions {
            if let identifier = await scheduleNotification(
                for: event,
                on: date,
                minutesBefore: minutes
            ) {
                identifiers.append(identifier)
            }
        }

        
        return identifiers
    }

    // MARK: - Notification Cancellation

    /// Cancel specific notifications by their identifiers
    func cancelNotifications(with identifiers: [String]) {
        guard !identifiers.isEmpty else { return }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        
    }

    /// Cancel all notifications for a specific event
    func cancelAllNotifications(for eventId: UUID) async {
        let pendingRequests = await notificationCenter.pendingNotificationRequests()
        let identifiersToCancel = pendingRequests
            .filter { $0.identifier.hasPrefix(eventId.uuidString) }
            .map { $0.identifier }

        cancelNotifications(with: identifiersToCancel)
    }

    /// Get all pending notifications
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }

    /// Clear badge count
    func clearBadge() {
        notificationCenter.setBadgeCount(0)
    }
}
