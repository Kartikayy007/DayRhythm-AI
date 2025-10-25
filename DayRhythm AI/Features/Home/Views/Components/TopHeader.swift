//
//  TopHeader.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI




struct TopHeader: View {
    
    @StateObject private var viewModel: TopHeaderViewModel
    
    
    init(homeViewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: TopHeaderViewModel(homeViewModel: homeViewModel))
    }
    
    
    var body: some View {
        content
            .topHeaderBackground()
            .sheet(isPresented: $viewModel.showMonthPicker) {
                monthPickerSheet
            }
    }
}


private extension TopHeader {
    
    var content: some View {
        VStack(spacing: 0) {
            headerBar
            weekRow
        }
    }
    
    
    var headerBar: some View {
        HeaderTopBar(
            currentMonth: viewModel.currentMonth,
            fullDateDisplay: viewModel.fullDateDisplay,
            selectedDate: viewModel.selectedDate,
            onMonthPickerTap: viewModel.handleMonthPickerTap
        )
    }
    
    
    var weekRow: some View {
        SimpleWeekView(viewModel: viewModel)
    }
    
    
    var monthPickerSheet: some View {
        MonthPickerView(
            selectedMonth: $viewModel.localSelectedMonth,
            onDone: viewModel.confirmMonthSelection
        )
    }
}
