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
        VStack(spacing: 6) {
            Text(day.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.8))

            Text("\(day.number)")
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 36, height: 36)
                .background(
                    ZStack {
                        
                        if day.isToday {
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        }

                        
                        Circle()
                            .fill(day.isSelected ? Color.white : Color.clear)
                            .shadow(color: day.isSelected ? Color.black.opacity(0.15) : .clear,
                                    radius: 4, x: 0, y: 2)
                    }
                )
                .scaleEffect(day.isSelected ? 1.05 : 1.0)
                .foregroundColor(day.isSelected ? .appAccent : .white)

            
            if !day.eventColors.isEmpty {
                HStack(spacing: 3) {
                    ForEach(0..<min(day.eventColors.count, 3), id: \.self) { index in
                        Circle()
                            .fill(day.eventColors[index])
                            .frame(width: 4, height: 4)
                    }
                }
                .padding(.top, 2)
            } else {
                
                Color.clear
                    .frame(height: 4)
                    .padding(.top, 2)
            }
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
