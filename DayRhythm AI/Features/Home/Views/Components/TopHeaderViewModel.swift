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

    let homeViewModel: HomeViewModel  // Made public for SimpleWeekView
    private var cancellables = Set<AnyCancellable>()

    var currentMonth: String {
        homeViewModel.currentMonth
    }

    var fullDateDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: homeViewModel.selectedDate)
    }

    var selectedDate: Date {
        homeViewModel.selectedDate
    }

    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
        self.localSelectedMonth = homeViewModel.selectedDate

        // Subscribe to selectedDate changes to update localSelectedMonth
        homeViewModel.$selectedDate
            .sink { [weak self] date in
                self?.localSelectedMonth = date
            }
            .store(in: &cancellables)
    }

    func goToToday() {
        withAnimation {
            homeViewModel.selectDate(Date())
        }
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
        withAnimation {
            homeViewModel.selectDate(date)
        }
    }

    func confirmMonthSelection() {
        withAnimation {
            homeViewModel.selectDate(localSelectedMonth)
        }
        showMonthPicker = false
    }
}
