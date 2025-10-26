//
//  CircularDayDial.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI
import Combine

struct RadialSegment: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let innerRadius: CGFloat = 40

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        let innerStartX = center.x + innerRadius * cos(startAngle.radians)
        let innerStartY = center.y + innerRadius * sin(startAngle.radians)
        path.move(to: CGPoint(x: innerStartX, y: innerStartY))

        path.addArc(center: center, radius: innerRadius,
                   startAngle: startAngle, endAngle: endAngle, clockwise: false)

        let outerEndX = center.x + radius * cos(endAngle.radians)
        let outerEndY = center.y + radius * sin(endAngle.radians)
        path.addLine(to: CGPoint(x: outerEndX, y: outerEndY))

        path.addArc(center: center, radius: radius,
                   startAngle: endAngle, endAngle: startAngle, clockwise: true)

        path.closeSubpath()

        return path
    }
}

enum ClockMode: String, CaseIterable {
    case twentyFourHour = "24h"
    case twelveHourDay = "Day"
    case twelveHourNight = "Night"

    var hourRange: ClosedRange<Double> {
        switch self {
        case .twentyFourHour:
            return 0...24
        case .twelveHourDay:
            return 6...18
        case .twelveHourNight:
            return 18...30
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
    var highlightedEventId: UUID? = nil
    var onEventTimeChange: ((UUID, Double, Double) -> Void)? = nil

    @State private var clockMode: ClockMode = .twentyFourHour
    @StateObject private var motionManager = MotionManager()
    @State private var currentTime = Date()
    @State private var dragStartAngle: Double = 0
    @State private var isDraggingStart = false
    @State private var isDraggingEnd = false
    @State private var isDraggingMiddle = false
    @State private var selectedArcId: UUID?

    private let dialSize: CGFloat = 320
    private let strokeWidth: CGFloat = 1
    private let tickLength: CGFloat = 8
    private let majorTickLength: CGFloat = 15
    private let arcWidth: CGFloat = 8

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    private var currentHour: Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentTime)
        let minute = calendar.component(.minute, from: currentTime)
        let second = calendar.component(.second, from: currentTime)
        let nanosecond = calendar.component(.nanosecond, from: currentTime)
        return Double(hour) + Double(minute) / 60.0 + Double(second) / 3600.0 + Double(nanosecond) / (3600.0 * 1_000_000_000)
    }

    private var currentMinute: Double {
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: currentTime)
        let second = calendar.component(.second, from: currentTime)
        return Double(minute) + Double(second) / 60.0
    }

    private var currentSecond: Double {
        let calendar = Calendar.current
        let second = calendar.component(.second, from: currentTime)
        let nanosecond = calendar.component(.nanosecond, from: currentTime)
        return Double(second) + Double(nanosecond) / 1_000_000_000
    }
    
    private var totalScheduledHours: Double {
        filteredEvents.reduce(0) { $0 + $1.duration }
    }
    
    private var filteredEvents: [DayEvent] {
        events.filter { event in
            switch clockMode {
            case .twentyFourHour:
                return true
            case .twelveHourDay:
                return event.startHour >= 6.0 && event.startHour < 18.0
            case .twelveHourNight:
                return event.startHour >= 18.0 || event.startHour < 6.0
            }
        }
    }
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate).uppercased()
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: selectedDate)
    }
    
    private var scheduledTimeText: String {
        let hours = Int(totalScheduledHours)
        let minutes = Int((totalScheduledHours - Double(hours)) * 60)
        return String(format: "%dh%02dm scheduled", hours, minutes)
    }
    
    var body: some View {
        VStack(spacing: 20) {
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
            
            ZStack {
                hourMarkers

                ForEach(filteredEvents) { event in
                    let isHighlighted = highlightedEventId == event.id
                    eventArc(for: event, isHighlighted: isHighlighted)
                        .gesture(isHighlighted && onEventTimeChange != nil ? dragGesture : nil)
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
            .onReceive(timer) { _ in
                currentTime = Date()
            }
        }
    }
}

private extension CircularDayDial {

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard let highlightedEvent = filteredEvents.first(where: { $0.id == highlightedEventId }) else { return }

                let location = value.location
                let center = CGPoint(x: dialSize / 2, y: dialSize / 2)
                let dx = location.x - center.x
                let dy = location.y - center.y

                let angle = atan2(dy, dx) * 180 / .pi + 90
                let normalizedAngle = angle < 0 ? angle + 360 : angle

                let startAngle = (highlightedEvent.startHour / 24) * 360
                let endAngle = (highlightedEvent.endHour / 24) * 360
                let arcSize = endAngle - startAngle

                let distFromStart = abs(normalizedAngle - startAngle)
                let distFromEnd = abs(normalizedAngle - endAngle)
                let edgeThreshold: Double = 30

                if distFromStart < edgeThreshold {
                    isDraggingStart = true
                    isDraggingEnd = false
                    isDraggingMiddle = false
                } else if distFromEnd < edgeThreshold {
                    isDraggingStart = false
                    isDraggingEnd = true
                    isDraggingMiddle = false
                } else if normalizedAngle > startAngle && normalizedAngle < endAngle {
                    isDraggingStart = false
                    isDraggingEnd = false
                    isDraggingMiddle = true
                }

                dragStartAngle = normalizedAngle

                
                let hourValue = (normalizedAngle / 360) * 24
                var newStartHour = highlightedEvent.startHour
                var newEndHour = highlightedEvent.endHour

                if isDraggingStart {
                    newStartHour = hourValue
                    if newStartHour >= newEndHour {
                        newStartHour = newEndHour - 0.5
                    }
                } else if isDraggingEnd {
                    newEndHour = hourValue
                    if newEndHour <= newStartHour {
                        newEndHour = newStartHour + 0.5
                    }
                } else if isDraggingMiddle {
                    let duration = highlightedEvent.endHour - highlightedEvent.startHour
                    let deltaAngle = normalizedAngle - dragStartAngle
                    let deltaHour = (deltaAngle / 360) * 24
                    newStartHour = (highlightedEvent.startHour + deltaHour).truncatingRemainder(dividingBy: 24)
                    newEndHour = (newStartHour + duration).truncatingRemainder(dividingBy: 24)
                }

                onEventTimeChange?(highlightedEvent.id, newStartHour, newEndHour)
            }
            .onEnded { value in
                isDraggingStart = false
                isDraggingEnd = false
                isDraggingMiddle = false
            }
    }

    var hourMarkers: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: strokeWidth)
            
            ForEach(0..<60) { index in
                tick(at: index)
            }

            switch clockMode {
            case .twentyFourHour:
                hourNumber("00", angle: 0)
                hourNumber("02", angle: 30)
                hourNumber("04", angle: 60)
                hourNumber("06", angle: 90)
                hourNumber("08", angle: 120)
                hourNumber("10", angle: 150)    
                hourNumber("12", angle: 180)    
                hourNumber("14", angle: 210)    
                hourNumber("16", angle: 240)    
                hourNumber("18", angle: 270)    
                hourNumber("20", angle: 300)    
                hourNumber("22", angle: 330)    
            case .twelveHourDay, .twelveHourNight:
                
                hourNumber("12", angle: 0)      
                hourNumber("1", angle: 30)      
                hourNumber("2", angle: 60)      
                hourNumber("3", angle: 90)      
                hourNumber("4", angle: 120)     
                hourNumber("5", angle: 150)     
                hourNumber("6", angle: 180)     
                hourNumber("7", angle: 210)     
                hourNumber("8", angle: 240)     
                hourNumber("9", angle: 270)     
                hourNumber("10", angle: 300)    
                hourNumber("11", angle: 330)    
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
        
        let radians = (angle - 90) * .pi / 180
        let x = cos(radians) * (dialSize / 2 - 35)
        let y = sin(radians) * (dialSize / 2 - 35)

        return Text(text)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white.opacity(0.8))
            .offset(x: x, y: y)
    }
    
    var currentTimeIndicator: some View {
        let calendar = Calendar.current
        let hour = Double(calendar.component(.hour, from: currentTime))
        let minute = Double(calendar.component(.minute, from: currentTime))
        let second = Double(calendar.component(.second, from: currentTime))

        let secondAngle = (second / 60) * 360
        let minuteAngle = (minute / 60) * 360 + (second / 60) * 6

        let hourAngle: Double = {
            switch clockMode {
            case .twentyFourHour:
                let totalMinutes = hour * 60 + minute
                return (totalMinutes / (24 * 60)) * 360
            case .twelveHourDay, .twelveHourNight:
                let hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
                let totalMinutes = hour12 * 60 + minute
                return (totalMinutes / (12 * 60)) * 360
            }
        }()

        return ZStack {
            Rectangle()
                .fill(Color.cyan)
                .frame(width: 3, height: dialSize / 3)
                .offset(y: -dialSize / 6)
                .rotationEffect(.degrees(hourAngle), anchor: .center)

            Rectangle()
                .fill(Color.cyan.opacity(0.8))
                .frame(width: 2, height: dialSize / 2.5)
                .offset(y: -dialSize / 5)
                .rotationEffect(.degrees(minuteAngle), anchor: .center)

            Rectangle()
                .fill(Color.cyan.opacity(0.6))
                .frame(width: 0.5, height: dialSize / 2.2)
                .offset(y: -dialSize / 4.4)
                .rotationEffect(.degrees(secondAngle), anchor: .center)
                .animation(.linear(duration: 0.1), value: secondAngle)

            Circle()
                .fill(Color.cyan)
                .frame(width: 8, height: 8)
        }
    }
    
    func normalizeHourForMode(_ hour: Double) -> Double {
        switch clockMode {
        case .twentyFourHour:
            return hour
        case .twelveHourDay:
            return hour > 12 ? hour - 12 : hour
        case .twelveHourNight:
            return hour > 12 ? hour - 12 : hour
        }
    }
    
    func eventArc(for event: DayEvent, isHighlighted: Bool = true) -> some View {
        let startAngle: Angle
        let endAngle: Angle

        switch clockMode {
        case .twentyFourHour:
            startAngle = .degrees((event.startHour / 24) * 360 - 90)
            endAngle = .degrees((event.endHour / 24) * 360 - 90)

        case .twelveHourDay, .twelveHourNight:
            var start12 = event.startHour
            if start12 > 12 {
                start12 = start12 - 12
            } else if start12 == 0 {
                start12 = 12
            }

            var end12 = event.endHour
            if end12 > 12 {
                end12 = end12 - 12
            } else if end12 == 0 {
                end12 = 12
            }

            startAngle = .degrees((start12 / 12) * 360 - 90)
            endAngle = .degrees((end12 / 12) * 360 - 90)
        }

        let fillOpacity: Double
        let strokeOpacity: Double
        let strokeWidth: CGFloat

        if onEventTimeChange != nil || highlightedEventId != nil {
            
            fillOpacity = isHighlighted ? 0.85 : 0.15
            strokeOpacity = isHighlighted ? 1.0 : 0.3
            strokeWidth = isHighlighted ? 2.5 : 1.5
        } else {
            
            fillOpacity = 0.30
            strokeOpacity = 0.8
            strokeWidth = 1.5
        }

        return RadialSegment(startAngle: startAngle, endAngle: endAngle)
            .fill(event.color.opacity(fillOpacity))
            .overlay(
                RadialSegment(startAngle: startAngle, endAngle: endAngle)
                    .stroke(event.color.opacity(strokeOpacity), lineWidth: strokeWidth)
            )
            .frame(width: dialSize, height: dialSize)
    }
    
    var centerContent: some View {
        VStack(spacing: 8) {
            Text(dayName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            Text(dateString)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.9))

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
                DayEvent(title: "Morning Routine", startHour: 6, duration: 2, color: .purple, category: "Personal",
                        emoji: "☀️", description: "Start the day", participants: [], isCompleted: false),
                DayEvent(title: "Deep Work", startHour: 9, duration: 4, color: .blue, category: "Work",
                        emoji: "💻", description: "Focus time", participants: [], isCompleted: false),
                DayEvent(title: "Lunch Break", startHour: 13, duration: 1, color: .green, category: "Break",
                        emoji: "🍔", description: "Lunch time", participants: [], isCompleted: false),
                DayEvent(title: "Meetings", startHour: 14, duration: 2, color: .orange, category: "Work",
                        emoji: "📅", description: "Team sync", participants: ["John", "Sarah"], isCompleted: false),
                DayEvent(title: "Exercise", startHour: 17, duration: 1, color: .red, category: "Health",
                        emoji: "🏃", description: "Workout", participants: [], isCompleted: false),
                DayEvent(title: "Dinner", startHour: 19, duration: 1, color: .yellow, category: "Personal",
                        emoji: "🍽️", description: "Family dinner", participants: [], isCompleted: false),
                DayEvent(title: "Reading", startHour: 21, duration: 1.5, color: .cyan, category: "Learning",
                        emoji: "📚", description: "Personal development", participants: [], isCompleted: false),
                DayEvent(title: "Sleep", startHour: 23, duration: 7, color: .indigo, category: "Rest",
                        emoji: "😴", description: "Rest time", participants: [], isCompleted: false)
            ],
            selectedDate: Date()
        )
        .padding()
    }
}
