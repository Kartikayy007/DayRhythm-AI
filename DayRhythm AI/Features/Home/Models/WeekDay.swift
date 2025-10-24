//
//  WeekDay.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import Foundation


struct WeekDay: Identifiable {
    let id = UUID()
    let name: String
    let number: Int
    let date: Date
    let isSelected: Bool
    var isToday: Bool = false
}
