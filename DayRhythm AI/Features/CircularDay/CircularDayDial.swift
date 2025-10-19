//
//  CircularDayDial.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI

enum ClockMode: String, CaseIterable {
    case twentyFourHour = "24h"
    case twelveHourDay = "Day"
    case twelveHourNight = "Night"
    
    var hourRange: ClosedRange<Double> {
        switch self {
        case .twentyFourHour:
            return 0...24
        case .twelveHourDay:
            return 6...18  // 6 AM to 6 PM
        case .twelveHourNight:
            return 18...30  // 6 PM to 6 AM (represented as 18-30 for easier math)
        }
    }
    
    var startHour: Double {
        hourRange.lowerBound
    }
    
    var duration: Double {
        switch self {
        case .twentyFourHour:
            return 24
        case .twelveHourDay, .twelveHourNight:
            return 12
        }
    }
}

struct CircularDayDial: View {
    let events: [DayEvent]
    let selectedDate: Date
    
    @State private var clockMode: ClockMode = .twentyFourHour
    @StateObject private var motionManager = MotionManager()
    
    private let dialSize: CGFloat = 320
    private let strokeWidth: CGFloat = 2
    private let tickLength: CGFloat = 8
    private let majorTickLength: CGFloat = 15
    private let arcWidth: CGFloat = 30
    
    private var currentHour: Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let minute = calendar.component(.minute, from: Date())
        return Double(hour) + Double(minute) / 60.0
    }
    
    private var totalScheduledHours: Double {
        filteredEvents.reduce(0) { $0 + $1.duration }
    }
    
    private var filteredEvents: [DayEvent] {
        events.filter { event in
            let eventEnd = event.startHour + event.duration
            switch clockMode {
            case .twentyFourHour:
                return true
            case .twelveHourDay:
                return event.startHour < 18 && event.startHour >= 6
            case .twelveHourNight:
                return event.startHour >= 18 || event.startHour < 6
            }
        }
    }
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate).uppercased()
    }
    
    private var scheduledTimeText: String {
        let hours = Int(totalScheduledHours)
        let minutes = Int((totalScheduledHours - Double(hours)) * 60)
        return String(format: "%dh%02dm scheduled", hours, minutes)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Mode Selector
            HStack(spacing: 12) {
                ForEach(ClockMode.allCases, id: \.self) { mode in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            clockMode = mode
                        }
                    }) {
                        Text(mode.rawValue)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(clockMode == mode ? .black : .white.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(clockMode == mode ? Color.white : Color.white.opacity(0.1))
                            )
                    }
                }
            }
            
            // Clock Dial
            ZStack {
                hourMarkers
                
                ForEach(filteredEvents) { event in
                    eventArc(for: event)
                }
                
                currentTimeIndicator
                
                centerContent
            }
            .frame(width: dialSize, height: dialSize)
            .rotation3DEffect(
                .radians(motionManager.pitch),
                axis: (x: 1, y: 0, z: 0),
                perspective: 0.5
            )
            .rotation3DEffect(
                .radians(motionManager.roll),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
            .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
        }
    }
}

private extension CircularDayDial {
    
    var hourMarkers: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: strokeWidth)
            
            ForEach(0..<(clockMode == .twentyFourHour ? 60 : 60)) { index in
                tick(at: index)
            }
            
            // Hour numbers based on mode
            if clockMode == .twentyFourHour {
                hourNumber("00", angle: -90)
                hourNumber("06", angle: 0)
                hourNumber("12", angle: 90)
                hourNumber("18", angle: 180)
            } else {
                hourNumber(getHourLabel(0), angle: -90)
                hourNumber(getHourLabel(3), angle: 0)
                hourNumber(getHourLabel(6), angle: 90)
                hourNumber(getHourLabel(9), angle: 180)
            }
        }
    }
    
    func getHourLabel(_ offset: Int) -> String {
        let startHour = Int(clockMode.startHour)
        let hour = (startHour + offset * 3) % 24
        if clockMode == .twelveHourDay || clockMode == .twelveHourNight {
            let displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
            return String(format: "%02d", displayHour)
        }
        return String(format: "%02d", hour)
    }
    
    func tick(at index: Int) -> some View {
        let isMajor = index % 5 == 0
        let length = isMajor ? majorTickLength : tickLength
        let width: CGFloat = isMajor ? 2 : 1
        
        return Rectangle()
            .fill(Color.white.opacity(isMajor ? 0.6 : 0.3))
            .frame(width: width, height: length)
            .offset(y: -dialSize / 2 + length / 2)
            .rotationEffect(.degrees(Double(index) * 6))
    }
    
    func hourNumber(_ text: String, angle: Double) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white.opacity(0.8))
            .offset(y: -dialSize / 2 + 40)
            .rotationEffect(.degrees(angle))
    }
    
    var currentTimeIndicator: some View {
        let normalizedHour = normalizeHourForMode(currentHour)
        let angle = (normalizedHour / clockMode.duration) * 360 - 90
        
        return ZStack {
            // Glowing dot at the end
            Circle()
                .fill(Color.cyan)
                .frame(width: 12, height: 12)
                .shadow(color: .cyan, radius: 8)
                .offset(y: -dialSize / 2 + arcWidth / 2)
            
            // Thin line from center
            Rectangle()
                .fill(Color.cyan.opacity(0.8))
                .frame(width: 2, height: dialSize / 2 - arcWidth / 2)
                .offset(y: -(dialSize / 2 - arcWidth / 2) / 2)
        }
        .rotationEffect(.degrees(angle))
    }
    
    func normalizeHourForMode(_ hour: Double) -> Double {
        switch clockMode {
        case .twentyFourHour:
            return hour
        case .twelveHourDay:
            return max(0, min(12, hour - 6))
        case .twelveHourNight:
            if hour >= 18 {
                return hour - 18
            } else {
                return hour + 6
            }
        }
    }
    
    func eventArc(for event: DayEvent) -> some View {
        let normalizedStart = normalizeHourForMode(event.startHour)
        let startFraction = normalizedStart / clockMode.duration
        let endFraction = (normalizedStart + event.duration) / clockMode.duration
        
        return Circle()
            .trim(from: startFraction, to: min(1.0, endFraction))
            .stroke(event.color, style: StrokeStyle(lineWidth: arcWidth, lineCap: .round))
            .frame(width: (dialSize - arcWidth) , height: (dialSize - arcWidth))
            .rotationEffect(.degrees(-90))
    }
    
    var centerContent: some View {
        VStack(spacing: 8) {
            Text(dayName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(scheduledTimeText)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
            
            if let firstEvent = filteredEvents.first {
                VStack(spacing: 2) {
                    Text(firstEvent.category.uppercased())
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(firstEvent.color.opacity(0.8))
                    
                    Text(firstEvent.title.uppercased())
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(formatEventTime(firstEvent))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 8)
            }
        }
    }
    
    func formatEventTime(_ event: DayEvent) -> String {
        let hours = Int(event.duration)
        let minutes = Int((event.duration - Double(hours)) * 60)
        return String(format: "%dh%02dm", hours, minutes)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        CircularDayDial(
            events: [
                DayEvent(title: "Morning Routine", startHour: 6, duration: 2, color: .purple, category: "Personal"),
                DayEvent(title: "Deep Work", startHour: 9, duration: 4, color: .blue, category: "Work"),
                DayEvent(title: "Lunch Break", startHour: 13, duration: 1, color: .green, category: "Break"),
                DayEvent(title: "Meetings", startHour: 14, duration: 2, color: .orange, category: "Work"),
                DayEvent(title: "Exercise", startHour: 17, duration: 1, color: .red, category: "Health"),
                DayEvent(title: "Dinner", startHour: 19, duration: 1, color: .yellow, category: "Personal"),
                DayEvent(title: "Reading", startHour: 21, duration: 1.5, color: .cyan, category: "Learning"),
                DayEvent(title: "Sleep", startHour: 23, duration: 7, color: .indigo, category: "Rest")
            ],
            selectedDate: Date()
        )
        .padding()
    }
}
