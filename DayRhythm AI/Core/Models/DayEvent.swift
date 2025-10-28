//
//  DayEvent.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI

struct DayEvent: Identifiable {
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
        isCompleted: Bool
    ) {
        self.id = id
        self.title = title
        self.startHour = startHour
        self.endHour = endHour
        self.color = color
        self.category = category
        self.emoji = emoji
        self.description = description
        self.participants = participants
        self.isCompleted = isCompleted
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
