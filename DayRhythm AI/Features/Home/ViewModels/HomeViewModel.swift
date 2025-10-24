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
    @Published var eventsByDate: [String: [DayEvent]] = [:]

    var events: [DayEvent] {
        let dateKey = dateKeyFor(selectedDate)
        return eventsByDate[dateKey] ?? []
    }

    var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: selectedDate)
    }

    var currentTaskId: UUID? {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let currentHour = Double(hour) + Double(minute) / 60.0

        return events.first(where: { event in
            event.startHour <= currentHour && currentHour < event.endHour
        })?.id
    }


    init() {
        loadSampleEvents()
    }

    private func loadSampleEvents() {}

    private func dateKeyFor(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func addEvent(_ event: DayEvent, repeatDaily: Bool = false) {
        if repeatDaily {
            for dayOffset in 0..<30 {
                if let targetDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: selectedDate) {
                    let dateKey = dateKeyFor(targetDate)
                    if eventsByDate[dateKey] != nil {
                        eventsByDate[dateKey]?.append(event)
                    } else {
                        eventsByDate[dateKey] = [event]
                    }
                }
            }
        } else {
            let dateKey = dateKeyFor(selectedDate)
            if eventsByDate[dateKey] != nil {
                eventsByDate[dateKey]?.append(event)
            } else {
                eventsByDate[dateKey] = [event]
            }
        }
        objectWillChange.send()
    }

    func selectDate(_ date: Date) {
        selectedDate = date
    }

    func moveToNextDay() {
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            selectedDate = nextDay
        }
    }

    func moveToPreviousDay() {
        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = previousDay
        }
    }

    func deleteEvent(_ event: DayEvent) {
        let dateKey = dateKeyFor(selectedDate)
        eventsByDate[dateKey]?.removeAll { $0.id == event.id }
        objectWillChange.send()
    }

    func updateEvent(_ oldEvent: DayEvent, with newEvent: DayEvent) {
        let dateKey = dateKeyFor(selectedDate)
        if let index = eventsByDate[dateKey]?.firstIndex(where: { $0.id == oldEvent.id }) {
            eventsByDate[dateKey]?[index] = newEvent
            objectWillChange.send()
        }
    }
}
