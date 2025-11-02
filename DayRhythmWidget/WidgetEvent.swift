//
//  WidgetEvent.swift
//  DayRhythmWidget
//
//  Created by Kartikay on 02/11/25.
//

import Foundation
import SwiftUI


struct WidgetEvent: Codable, Identifiable {
    let id: UUID
    let title: String
    let startHour: Double
    let endHour: Double
    let colorHex: String
    let emoji: String

    var duration: Double {
        endHour - startHour
    }

    var color: Color {
        Color(hex: colorHex) ?? Color.appPrimary
    }

    var timeString: String {
        let startTime = formatTime(startHour)
        let endTime = formatTime(endHour)
        return "\(startTime) - \(endTime)"
    }

    private func formatTime(_ hour: Double) -> String {
        let h = Int(hour)
        let m = Int((hour - Double(h)) * 60)
        let period = h >= 12 ? "PM" : "AM"
        let displayHour = h > 12 ? h - 12 : (h == 0 ? 12 : h)
        return String(format: "%d:%02d %@", displayHour, m, period)
    }
}