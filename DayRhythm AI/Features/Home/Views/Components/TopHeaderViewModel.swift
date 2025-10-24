//
//  TopHeaderViewModel.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI
import Combine


final class TopHeaderViewModel: ObservableObject {

    @Published var showMonthPicker: Bool = false
    @Published var localSelectedMonth: Date = Date()
    @Published var weekDays: [WeekDay] = []

    private let homeViewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()

    var currentMonth: String {
        homeViewModel.currentMonth
    }

    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
        self.localSelectedMonth = homeViewModel.selectedDate

        // Subscribe to selectedDate changes to update week days
        homeViewModel.$selectedDate
            .sink { [weak self] date in
                self?.updateWeekDays(for: date)
            }
            .store(in: &cancellables)

        // Initial week days
        updateWeekDays(for: homeViewModel.selectedDate)
    }

    private func updateWeekDays(for date: Date) {
        weekDays = generateWeekDays(for: date)
    }

    private func generateWeekDays(for date: Date) -> [WeekDay] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let weekStart = calendar.date(byAdding: .day, value: -(weekday - 1), to: date)!
        let today = Date()

        return (0..<7).map { offset in
            let dayDate = calendar.date(byAdding: .day, value: offset, to: weekStart)!
            let dayName = calendar.shortWeekdaySymbols[offset]
            let dayNumber = calendar.component(.day, from: dayDate)
            let isSelected = calendar.isDate(dayDate, inSameDayAs: date)
            let isToday = calendar.isDate(dayDate, inSameDayAs: today)

            return WeekDay(
                name: dayName,
                number: dayNumber,
                date: dayDate,
                isSelected: isSelected,
                isToday: isToday
            )
        }
    }

    func goToToday() {
        homeViewModel.selectDate(Date())
    }

    func handleMonthPickerTap() {
        localSelectedMonth = homeViewModel.selectedDate
        showMonthPicker = true
    }

    func handleProfileTap() {
        // TODO: Implement profile navigation
        print("Profile tapped")
    }

    func handleDaySelection(_ date: Date) {
        homeViewModel.selectDate(date)
    }

    func confirmMonthSelection() {
        homeViewModel.selectDate(localSelectedMonth)
        showMonthPicker = false
    }
}
