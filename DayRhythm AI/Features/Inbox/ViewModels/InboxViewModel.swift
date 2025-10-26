//
//  InboxViewModel.swift
//  DayRhythm AI
//
//  ViewModel for the Inbox feature - manages task display for selected date
//

import SwiftUI
import Combine

class InboxViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()

    private let homeViewModel: HomeViewModel

    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
    }

    var todayEvents: [DayEvent] {
        let dateKey = homeViewModel.dateKeyFor(selectedDate)
        return homeViewModel.eventsByDate[dateKey] ?? []
    }

    func moveToNextDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
    }

    func moveToPreviousDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
    }

    func selectDate(_ date: Date) {
        selectedDate = date
    }
}
