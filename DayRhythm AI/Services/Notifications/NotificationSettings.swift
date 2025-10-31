//
//  NotificationSettings.swift
//  DayRhythm AI
//
//  Created by kartikay on 31/10/25.
//

import Foundation

struct NotificationSettings: Codable, Equatable {
    /// Whether notifications are enabled for this event
    var enabled: Bool

    /// Array of minutes before event to trigger notifications
    /// For example: [15, 5] means notify 15 mins before AND 5 mins before
    var minutesBefore: [Int]

    /// Identifiers of scheduled notifications (for cancellation purposes)
    var notificationIds: [String]

    /// Default notification settings (disabled, no notifications)
    static let disabled = NotificationSettings(
        enabled: false,
        minutesBefore: [],
        notificationIds: []
    )

    /// Standard 15-minute reminder
    static let fifteenMinutes = NotificationSettings(
        enabled: true,
        minutesBefore: [15],
        notificationIds: []
    )

    /// Standard 5-minute reminder
    static let fiveMinutes = NotificationSettings(
        enabled: true,
        minutesBefore: [5],
        notificationIds: []
    )

    /// At time of event
    static let atTime = NotificationSettings(
        enabled: true,
        minutesBefore: [0],
        notificationIds: []
    )

    /// Multiple reminders: 15 min and 5 min before
    static let multipleReminders = NotificationSettings(
        enabled: true,
        minutesBefore: [15, 5],
        notificationIds: []
    )

    init(enabled: Bool, minutesBefore: [Int], notificationIds: [String] = []) {
        self.enabled = enabled
        self.minutesBefore = minutesBefore
        self.notificationIds = notificationIds
    }
}
