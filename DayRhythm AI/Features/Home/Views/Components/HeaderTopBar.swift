//
//  HeaderTopBar.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI


struct HeaderTopBar: View {
    let currentMonth: String
    let fullDateDisplay: String
    let selectedDate: Date
    let onMonthPickerTap: () -> Void

    var body: some View {
        HStack {
            // Use the animated date display with motion blur counter
            AnimatedDateDisplay(date: selectedDate)

            Button(action: onMonthPickerTap) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
        }
        .padding(.top, 8)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}

#Preview {
    HeaderTopBar(
        currentMonth: "October",
        fullDateDisplay: "25 October 2025",
        selectedDate: Date(),
        onMonthPickerTap: {}
    )
    .background(Color.appPrimary)
}
