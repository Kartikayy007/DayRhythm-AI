//
//  DayEvent.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI

enum SyncStatus: String, Codable {
    case local      
    case synced     
    case pending    
    case conflict   
}

struct DayEvent: Identifiable, Codable {
    let id: UUID
    let title: String
    let startHour: Double
    let endHour: Double
    let color: Color
    let category: String
    let emoji: String
    let description: String
    let participants: [String]
    let isCompleted: Bool
    var notificationSettings: NotificationSettings


    var cloudId: String?
    var syncStatus: SyncStatus = .local
    var lastModified: Date?
    var dateString: String = ""

    
    var ekEventIdentifier: String?     
    var ekCalendarIdentifier: String?  
    var isFromCalendar: Bool = false   


    var colorHex: String?

    init(
        id: UUID = UUID(),
        title: String,
        startHour: Double,
        endHour: Double,
        color: Color,
        category: String,
        emoji: String,
        description: String,
        participants: [String],
        isCompleted: Bool,
        notificationSettings: NotificationSettings = .disabled,
        cloudId: String? = nil,
        syncStatus: SyncStatus = .local,
        lastModified: Date? = nil,
        dateString: String = "",
        ekEventIdentifier: String? = nil,
        ekCalendarIdentifier: String? = nil,
        isFromCalendar: Bool = false
    ) {
        self.id = id
        self.title = title
        self.startHour = startHour
        self.endHour = endHour
        self.color = color
        self.colorHex = color.toHex()
        self.category = category
        self.emoji = emoji
        self.description = description
        self.participants = participants
        self.isCompleted = isCompleted
        self.notificationSettings = notificationSettings
        self.cloudId = cloudId
        self.syncStatus = syncStatus
        self.lastModified = lastModified
        self.dateString = dateString
        self.ekEventIdentifier = ekEventIdentifier
        self.ekCalendarIdentifier = ekCalendarIdentifier
        self.isFromCalendar = isFromCalendar
    }

    

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case startHour
        case endHour
        case colorHex
        case category
        case emoji
        case description
        case participants
        case isCompleted
        case notificationSettings
        case cloudId
        case syncStatus
        case lastModified
        case dateString
        case ekEventIdentifier
        case ekCalendarIdentifier
        case isFromCalendar
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        startHour = try container.decode(Double.self, forKey: .startHour)
        endHour = try container.decode(Double.self, forKey: .endHour)

        
        let hexString = try container.decodeIfPresent(String.self, forKey: .colorHex)
        self.colorHex = hexString
        self.color = Color(hex: hexString ?? "#FF6B35") ?? .orange

        category = try container.decode(String.self, forKey: .category)
        emoji = try container.decode(String.self, forKey: .emoji)
        description = try container.decode(String.self, forKey: .description)
        participants = try container.decode([String].self, forKey: .participants)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        notificationSettings = try container.decode(NotificationSettings.self, forKey: .notificationSettings)


        cloudId = try container.decodeIfPresent(String.self, forKey: .cloudId)
        syncStatus = try container.decodeIfPresent(SyncStatus.self, forKey: .syncStatus) ?? .local
        lastModified = try container.decodeIfPresent(Date.self, forKey: .lastModified)
        dateString = try container.decodeIfPresent(String.self, forKey: .dateString) ?? ""

        
        ekEventIdentifier = try container.decodeIfPresent(String.self, forKey: .ekEventIdentifier)
        ekCalendarIdentifier = try container.decodeIfPresent(String.self, forKey: .ekCalendarIdentifier)
        isFromCalendar = try container.decodeIfPresent(Bool.self, forKey: .isFromCalendar) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(startHour, forKey: .startHour)
        try container.encode(endHour, forKey: .endHour)
        try container.encode(colorHex ?? color.toHex(), forKey: .colorHex)
        try container.encode(category, forKey: .category)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(description, forKey: .description)
        try container.encode(participants, forKey: .participants)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(notificationSettings, forKey: .notificationSettings)

        try container.encodeIfPresent(cloudId, forKey: .cloudId)
        try container.encode(syncStatus, forKey: .syncStatus)
        try container.encodeIfPresent(lastModified, forKey: .lastModified)
        try container.encode(dateString, forKey: .dateString)

        
        try container.encodeIfPresent(ekEventIdentifier, forKey: .ekEventIdentifier)
        try container.encodeIfPresent(ekCalendarIdentifier, forKey: .ekCalendarIdentifier)
        try container.encode(isFromCalendar, forKey: .isFromCalendar)
    }

    var duration: Double {
        endHour - startHour
    }

    var timeString: String {
        let startTime = formatTime(startHour)
        let endTime = formatTime(endHour)
        return "\(startTime)–\(endTime)"
    }

    var durationString: String {
        let hours = Int(duration)
        let minutes = Int((duration - Double(hours)) * 60)
        if minutes > 0 {
            return "\(hours) h \(minutes)m"
        }
        return "\(hours) h"
    }

    private func formatTime(_ hour: Double) -> String {
        let h = Int(hour)
        let m = Int((hour - Double(h)) * 60)
        let period = h >= 12 ? "PM" : "AM"
        let displayHour = h > 12 ? h - 12 : (h == 0 ? 12 : h)
        return String(format: "%d:%02d %@", displayHour, m, period)
    }
}

extension DayEvent {
    static let sampleEvents: [DayEvent] = [
        DayEvent(title: "Morning Routine", startHour: 6, endHour: 9, color: .red, category: "Personal",
                emoji: "☀️", description: "Start the day", participants: [], isCompleted: false),
        DayEvent(title: "Focus Work", startHour: 10, endHour: 15, color: .green, category: "Work",
                emoji: "💻", description: "Deep work time", participants: [], isCompleted: false)
    ]
}
