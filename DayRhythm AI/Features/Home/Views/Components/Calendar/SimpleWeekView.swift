//  SimpleWeekView.swift
//  DayRhythm AI
//
//  Created by Kartikay on 25/10/25.
//


import SwiftUI
import UIKit



struct SimpleWeekView: View {
    @ObservedObject var viewModel: TopHeaderViewModel
    @State private var scrollProxy: ScrollViewProxy?
    @State private var currentWeekOffset: Int = 0

    
    private var weeks: [WeekData] {
        var result: [WeekData] = []
        let calendar = Calendar.current
        let baseDate = viewModel.selectedDate

        
        let weekday = calendar.component(.weekday, from: baseDate)
        let weekStart = calendar.date(byAdding: .day, value: -(weekday - 1), to: baseDate)!

        
        for weekOffset in -6...6 {
            if let weekDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: weekStart) {
                let weekDays = generateWeekDays(for: weekDate, weekId: weekOffset)
                result.append(WeekData(id: weekOffset, days: weekDays, startDate: weekDate))
            }
        }

        return result
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(weeks) { week in
                        WeekView(
                            days: week.days,
                            onDaySelected: { date in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.handleDaySelection(date)
                                }
                            }
                        )
                        .frame(width: UIScreen.main.bounds.width)
                        .id(week.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .frame(height: 80)
            .scrollPosition(id: .init(get: { currentWeekOffset }, set: { newValue in
                if let newValue = newValue, newValue != currentWeekOffset {
                    currentWeekOffset = newValue
                    
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
            }))
            .onAppear {
                
                DispatchQueue.main.async {
                    scrollProxy = proxy
                    proxy.scrollTo(0, anchor: .center)
                    currentWeekOffset = 0
                }
            }
            .onChange(of: viewModel.selectedDate) { newDate in
                scrollToWeekContaining(date: newDate, proxy: proxy)
            }
        }
    }

    private func generateWeekDays(for date: Date, weekId: Int) -> [WeekDay] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let weekStart = calendar.date(byAdding: .day, value: -(weekday - 1), to: date)!
        let today = Date()

        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"

        return (0..<7).map { offset in
            let dayDate = calendar.date(byAdding: .day, value: offset, to: weekStart)!
            let dayName = String(dayFormatter.string(from: dayDate).prefix(3))
            let dayNumber = calendar.component(.day, from: dayDate)
            let isSelected = calendar.isDate(dayDate, inSameDayAs: viewModel.selectedDate)
            let isToday = calendar.isDate(dayDate, inSameDayAs: today)

            
            let dateKey = viewModel.homeViewModel.dateKeyFor(dayDate)
            let dayEvents = viewModel.homeViewModel.eventsByDate[dateKey] ?? []
            let eventColors = Array(dayEvents.map { $0.color }.prefix(3))

            return WeekDay(
                name: dayName,
                number: dayNumber,
                date: dayDate,
                isSelected: isSelected,
                isToday: isToday,
                eventColors: eventColors
            )
        }
    }

    private func scrollToWeekContaining(date: Date, proxy: ScrollViewProxy) {
        let calendar = Calendar.current

        
        for week in weeks {
            if week.days.contains(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    proxy.scrollTo(week.id, anchor: .center)
                    currentWeekOffset = week.id
                }
                break
            }
        }
    }
}


private struct WeekData: Identifiable {
    let id: Int
    let days: [WeekDay]
    let startDate: Date
}


private struct WeekView: View {
    let days: [WeekDay]
    let onDaySelected: (Date) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(days) { day in
                WeekDayCell(day: day) {
                    onDaySelected(day.date)
                }
            }
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    ZStack {
        Color.appPrimary
            .ignoresSafeArea()

        SimpleWeekView(viewModel: TopHeaderViewModel(homeViewModel: HomeViewModel()))
    }
}