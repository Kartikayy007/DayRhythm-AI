//
//  MotionBlurDateView.swift
//  DayRhythm AI
//
//  Created by Kartikay on 25/10/25.
//

import SwiftUI

struct AnimatedDateDisplay: View {
    let date: Date

    private var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }

    private var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }

    private var year: Int {
        Calendar.current.component(.year, from: date)
    }

    var body: some View {
        HStack(spacing: 6) {
            Text("\(dayNumber)")
                .contentTransition(.numericText())
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(monthName)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .id(monthName)

            Text(verbatim: String(year))
                .contentTransition(.numericText())
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ZStack {
        Color.orange
            .ignoresSafeArea()

        AnimatedDateDisplay(date: Date())
    }
}
