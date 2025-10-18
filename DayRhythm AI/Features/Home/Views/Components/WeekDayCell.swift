//
//  WeekDayCell.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI


struct WeekDayCell: View {
    let day: WeekDay
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text(day.name)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            
            Text("\(day.number)")
                .font(.system(size: 20, weight: .semibold))
                .frame(width: 42, height: 42)
                .background(
                    Circle()
                        .fill(day.isSelected ? Color.white : Color.clear)
                        .shadow(color: day.isSelected ? Color.black.opacity(0.15) : .clear,
                                radius: 4, x: 0, y: 2)
                )
                .scaleEffect(day.isSelected ? 1.08 : 1.0)
                .foregroundColor(day.isSelected ? .appAccent : .white)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                onTap()
            }
        }
    }
}

#Preview {
    WeekDayCell(
        day: WeekDay(
            name: "Mon",
            number: 19,
            date: Date(),
            isSelected: true
        ),
        onTap: {}
    )
    .background(Color.appPrimary)
}
