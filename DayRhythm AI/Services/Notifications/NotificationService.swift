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

    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    @discardableResult
    func scheduleNotification(
        for event: DayEvent,
        on date: Date,
        minutesBefore: Int
    ) async -> String? {
        let status = await checkAuthorizationStatus()
        guard status == .authorized else {

            return nil
        }

        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)

        let notificationDate: Date?
        let content = UNMutableNotificationContent()
        content.title = event.emoji + " " + event.title

        if minutesBefore == -1 {
            
            let totalEndMinutes = Int(event.endHour * 60)
            let endHour = totalEndMinutes / 60
            let endMinute = totalEndMinutes % 60

            dateComponents.hour = endHour
            dateComponents.minute = endMinute
            dateComponents.second = 0

            notificationDate = calendar.date(from: dateComponents)
            content.body = "Task completed!"
        } else {
            
            let totalMinutes = Int(event.startHour * 60)
            let hour = totalMinutes / 60
            let minute = totalMinutes % 60

            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.second = 0

            guard let eventStartDate = calendar.date(from: dateComponents) else {
                return nil
            }

            notificationDate = calendar.date(byAdding: .minute, value: -minutesBefore, to: eventStartDate)

            if minutesBefore == 0 {
                content.body = "Your task is starting now"
            } else {
                content.body = "Starting in \(minutesBefore) minute\(minutesBefore == 1 ? "" : "s")"
            }
        }

        guard let finalNotificationDate = notificationDate else {
            return nil
        }

        let now = Date()
        guard finalNotificationDate.timeIntervalSince(now) > 5 else {
            return nil
        }

        if !event.description.isEmpty {
            content.subtitle = event.description
        }

        content.sound = .default
        content.badge = 1

        
        content.userInfo = ["eventId": event.id.uuidString]


        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: finalNotificationDate
        )

        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        
        let identifier = "\(event.id.uuidString)-\(minutesBefore)"

        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        
        do {
            try await notificationCenter.add(request)
            
            
            
            
            
            return identifier
        } catch {
            
            
            
            return nil
        }
    }

    
    
    
    
    
    
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

    

    
    func cancelNotifications(with identifiers: [String]) {
        guard !identifiers.isEmpty else { return }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        
    }

    
    func cancelAllNotifications(for eventId: UUID) async {
        let pendingRequests = await notificationCenter.pendingNotificationRequests()
        let identifiersToCancel = pendingRequests
            .filter { $0.identifier.hasPrefix(eventId.uuidString) }
            .map { $0.identifier }

        cancelNotifications(with: identifiersToCancel)
    }

    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }

    
    func clearBadge() {
        notificationCenter.setBadgeCount(0)
    }
}
