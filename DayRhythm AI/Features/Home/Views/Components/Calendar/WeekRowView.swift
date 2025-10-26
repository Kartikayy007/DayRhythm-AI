//
//  WeekRowView.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI


struct WeekRowView: View {
    let weekDays: [WeekDay]
    let onDaySelected: (Date) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDays) { day in
                WeekDayCell(day: day) {
                    onDaySelected(day.date)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 15)
    }
}

#Preview {
    WeekRowView(
        weekDays: [
            WeekDay(name: "Sun", number: 15, date: Date(), isSelected: false),
            WeekDay(name: "Mon", number: 16, date: Date(), isSelected: false),
            WeekDay(name: "Tue", number: 17, date: Date(), isSelected: false),
            WeekDay(name: "Wed", number: 18, date: Date(), isSelected: false),
            WeekDay(name: "Thu", number: 19, date: Date(), isSelected: true),
            WeekDay(name: "Fri", number: 20, date: Date(), isSelected: false),
            WeekDay(name: "Sat", number: 21, date: Date(), isSelected: false)
        ],
        onDaySelected: { _ in }
    )
    .background(Color.appPrimary)
}
