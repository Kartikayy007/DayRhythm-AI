//
//  HomeViewModel.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {
    
    @Published var selectedDate: Date = Date()
    @Published var events: [DayEvent] = []
    
    var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: selectedDate)
    }
    
    var weekDays: [WeekDay] {
        generateWeekDays(for: selectedDate)
    }
    
    init() {
        loadSampleEvents()
    }
    
    private func loadSampleEvents() {
        events = [
            DayEvent(title: "Morning Routine", startHour: 6, duration: 2, color: .purple, category: "Personal"),
            DayEvent(title: "Deep Work", startHour: 9, duration: 4, color: .blue, category: "Work"),
            DayEvent(title: "Lunch Break", startHour: 13, duration: 1, color: .green, category: "Break"),
            DayEvent(title: "Meetings", startHour: 14, duration: 2, color: .orange, category: "Work"),
            DayEvent(title: "Exercise", startHour: 17, duration: 1, color: .red, category: "Health"),
            DayEvent(title: "Dinner", startHour: 19, duration: 1, color: .yellow, category: "Personal"),
            DayEvent(title: "Reading", startHour: 21, duration: 1.5, color: .cyan, category: "Learning"),
            DayEvent(title: "Sleep", startHour: 23, duration: 7, color: .indigo, category: "Rest")
        ]
    }
    
    private func generateWeekDays(for date: Date) -> [WeekDay] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let weekStart = calendar.date(byAdding: .day, value: -(weekday - 1), to: date)!
        
        return (0..<7).map { offset in
            let dayDate = calendar.date(byAdding: .day, value: offset, to: weekStart)!
            let dayName = calendar.shortWeekdaySymbols[offset]
            let dayNumber = calendar.component(.day, from: dayDate)
            let isSelected = calendar.isDate(dayDate, inSameDayAs: selectedDate)
            
            return WeekDay(
                name: dayName,
                number: dayNumber,
                date: dayDate,
                isSelected: isSelected
            )
        }
    }
}
