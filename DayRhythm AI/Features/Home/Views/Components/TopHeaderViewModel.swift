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
    
    
    private let homeViewModel: HomeViewModel
    
    
    var currentMonth: String {
        homeViewModel.currentMonth
    }
    
    var weekDays: [WeekDay] {
        homeViewModel.weekDays
    }
    
    
    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
        self.localSelectedMonth = homeViewModel.selectedDate
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
        homeViewModel.selectedDate = date
    }
    
    
    func confirmMonthSelection() {
        homeViewModel.selectedDate = localSelectedMonth
        showMonthPicker = false
    }
}
