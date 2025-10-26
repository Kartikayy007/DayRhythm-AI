//
//  WeekDay.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import Foundation
import SwiftUI


struct WeekDay: Identifiable {
    let id = UUID()
    let name: String
    let number: Int
    let date: Date
    let isSelected: Bool
    var isToday: Bool = false
    var eventColors: [Color] = []  // Colors from events on this day (up to 3 shown)
}
