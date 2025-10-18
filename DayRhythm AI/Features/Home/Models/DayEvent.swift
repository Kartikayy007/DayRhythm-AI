//
//  DayEvent.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI


struct DayEvent: Identifiable {
    let id = UUID()
    let title: String
    let startHour: Double  // 0-24 (e.g., 9.5 = 9:30 AM)
    let duration: Double   // in hours (e.g., 2.5 = 2 hours 30 mins)
    let color: Color
    
    var endHour: Double {
        startHour + duration
    }
}


extension DayEvent {
    static let sampleEvents: [DayEvent] = [
        DayEvent(title: "Morning Routine", startHour: 6, duration: 3, color: .orange),
        DayEvent(title: "Focus Work", startHour: 10, duration: 5, color: .green)
    ]
}
