//
//  HomeViewModel.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var showMonthPicker = false
    @Published var events: [DayEvent] = []
    
    init() {
        loadEventsForSelectedDate()
    }
    
    var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: selectedDate)
    }
    
    var weekDays: [WeekDay] {
        let calendar = Calendar.current
        let weekdaySymbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        
        // Get the current week
        guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: selectedDate) else {
            return []
        }
        
        var days: [WeekDay] = []
        var currentDate = weekInterval.start
        
        for index in 0..<7 {
            let dayNumber = calendar.component(.day, from: currentDate)
            let isSelected = calendar.isDate(currentDate, inSameDayAs: selectedDate)
            
            days.append(WeekDay(
                name: weekdaySymbols[index],
                number: dayNumber,
                date: currentDate,
                isSelected: isSelected
            ))
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    var totalScheduledHours: Double {
        events.reduce(0) { $0 + $1.duration }
    }
    
    func toggleMonthPicker() {
        showMonthPicker.toggle()
    }
    
    func loadEventsForSelectedDate() {
        // TODO: Load from database/API
        // For now, using sample data
        events = [
            DayEvent(title: "FOCUS", startHour: 9, duration: 2.083, color: .green),
            DayEvent(title: "MEETING", startHour: 14, duration: 1.5, color: .orange)
        ]
    }
}
