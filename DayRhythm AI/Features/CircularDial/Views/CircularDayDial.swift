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
    case twelveHour = "12h"
    case twentyFourHour = "24h"

    var duration: Double {
        switch self {
        case .twelveHour:
            return 12
        case .twentyFourHour:
            return 24
        }
    }
}

enum TimeFilter: String, CaseIterable {
    case am = "AM"
    case pm = "PM"

    var hourRange: ClosedRange<Double> {
        switch self {
        case .am:
            return 0...11.99
        case .pm:
            return 12...23.99
        }
    }

    var icon: String {
        switch self {
        case .am:
            return "moon.fill"
        case .pm:
            return "sun.max.fill"
        }
    }
}

struct CircularDayDial: View {
    let events: [DayEvent]
    let selectedDate: Date
    var highlightedEventId: UUID? = nil
    var onEventTimeChange: ((UUID, Double, Double) -> Void)? = nil
    var onEventTap: ((DayEvent) -> Void)? = nil
    var onDragStateChange: ((Bool) -> Void)? = nil

    @State private var clockMode: ClockMode = .twentyFourHour
    @State private var timeFilter: TimeFilter = .am
    @StateObject private var motionManager = MotionManager()
    @State private var currentTime = Date()
    @State private var dragStartAngle: Double = 0
    @State private var isDraggingStart = false
    @State private var isDraggingEnd = false
    @State private var isDraggingMiddle = false
    @State private var selectedArcId: UUID?
    @State private var localHighlightedEventId: UUID? = nil
    @State private var lastHapticHour: Int = -1
    @State private var draggedEventTimes: [UUID: (start: Double, end: Double)] = [:]
    @State private var lastInteractionTime: Date? = nil

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
        filteredEvents.reduce(0) { total, event in
            let duration: Double
            switch clockMode {
            case .twentyFourHour:
                duration = event.duration
            case .twelveHour:
                
                let range = timeFilter.hourRange
                let visibleStart = max(event.startHour, range.lowerBound)
                let visibleEnd = min(event.endHour, range.upperBound)
                duration = max(0, visibleEnd - visibleStart)
            }
            return total + duration
        }
    }
    
    private var filteredEvents: [DayEvent] {
        events.filter { event in
            switch clockMode {
            case .twentyFourHour:
                return true 
            case .twelveHour:
                
                let range = timeFilter.hourRange
                
                return event.startHour < range.upperBound && event.endHour > range.lowerBound
            }
        }
    }

    private var currentOrUpcomingEvent: DayEvent? {
        
        if let currentEvent = filteredEvents.first(where: { event in
            currentHour >= event.startHour && currentHour < event.endHour
        }) {
            return currentEvent
        }

        
        return filteredEvents.first(where: { event in
            event.startHour > currentHour
        })
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
            
            HStack(spacing: 8) {
                
                Image(systemName: "clock")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))

                
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

                
                if clockMode == .twelveHour {
                    ForEach(TimeFilter.allCases, id: \.self) { filter in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                timeFilter = filter
                            }
                        }) {
                            Text(filter.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(timeFilter == filter ? .black : .white.opacity(0.6))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(timeFilter == filter ? Color.white : Color.white.opacity(0.1))
                                )
                        }
                    }
                }

                
                Button(action: {
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if clockMode == .twelveHour {
                            
                            let hour = Calendar.current.component(.hour, from: Date())
                            timeFilter = hour < 12 ? .am : .pm
                        }
                    }
                }) {
                    Text("Auto")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                        )
                }
            }
            
            ZStack {
                hourMarkers
                    .allowsHitTesting(false)

                ForEach(filteredEvents) { event in
                    let isHighlighted = (highlightedEventId == event.id || localHighlightedEventId == event.id)
                    eventArc(for: event, isHighlighted: isHighlighted)
                        .onTapGesture {
                            if localHighlightedEventId != event.id {
                                onEventTap?(event)
                            }
                        }
                        .gesture(
                            LongPressGesture(minimumDuration: 0.3)
                                .onEnded { _ in
                                    
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.prepare()
                                    impactFeedback.impactOccurred()

                                    
                                    onDragStateChange?(true)

                                    
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                        localHighlightedEventId = event.id
                                        selectedArcId = event.id
                                        lastInteractionTime = Date()
                                    }
                                }
                                .simultaneously(with: DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        if localHighlightedEventId == event.id {
                                            handleDragChanged(value: value, event: event)
                                        }
                                    }
                                    .onEnded { _ in
                                        if localHighlightedEventId == event.id {
                                            handleDragEnded(event: event)
                                        }
                                    }
                                )
                        )
                }

                currentTimeIndicator

                centerContent
            }
            .frame(width: dialSize, height: dialSize)
            .contentShape(Circle())
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
            .onTapGesture {
                if localHighlightedEventId != nil {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        localHighlightedEventId = nil
                        selectedArcId = nil
                        isDraggingStart = false
                        isDraggingEnd = false
                        isDraggingMiddle = false
                        dragStartAngle = 0
                        lastInteractionTime = nil
                    }
                    
                    onDragStateChange?(false)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        
                        
                    }
            )
            .onReceive(timer) { _ in
                currentTime = Date()

                
                if let lastTime = lastInteractionTime,
                   localHighlightedEventId != nil,
                   Date().timeIntervalSince(lastTime) > 10 {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        localHighlightedEventId = nil
                        selectedArcId = nil
                        isDraggingStart = false
                        isDraggingEnd = false
                        isDraggingMiddle = false
                        dragStartAngle = 0
                        lastInteractionTime = nil
                    }
                    onDragStateChange?(false)
                }
            }
        }
    }
}

private extension CircularDayDial {

    func handleDragChanged(value: DragGesture.Value, event: DayEvent) {
        
        lastInteractionTime = Date()

        let location = value.location
        let center = CGPoint(x: dialSize / 2, y: dialSize / 2)
        let dx = location.x - center.x
        let dy = location.y - center.y

        let angle = atan2(dy, dx) * 180 / .pi + 90
        let normalizedAngle = angle < 0 ? angle + 360 : angle

        
        let divisor = clockMode == .twentyFourHour ? 24.0 : 12.0
        let startAngle = (event.startHour / divisor) * 360
        let endAngle = (event.endHour / divisor) * 360

        
        let arcDuration = event.endHour - event.startHour
        let arcSizeInDegrees = (arcDuration / divisor) * 360

        
        let edgeThreshold: Double
        if arcSizeInDegrees < 30 {  
            
            edgeThreshold = 0
        } else if arcSizeInDegrees < 60 {  
            
            edgeThreshold = min(15, arcSizeInDegrees * 0.25)
        } else {  
            
            edgeThreshold = min(25, arcSizeInDegrees * 0.2)
        }

        let distFromStart = abs(normalizedAngle - startAngle)
        let distFromEnd = abs(normalizedAngle - endAngle)

        
        if dragStartAngle == 0 {
            if edgeThreshold > 0 && distFromStart < edgeThreshold {
                isDraggingStart = true
                isDraggingEnd = false
                isDraggingMiddle = false
            } else if edgeThreshold > 0 && distFromEnd < edgeThreshold {
                isDraggingStart = false
                isDraggingEnd = true
                isDraggingMiddle = false
            } else {
                
                isDraggingStart = false
                isDraggingEnd = false
                isDraggingMiddle = true
            }
            dragStartAngle = normalizedAngle
        }

        
        let hourValue: Double
        if clockMode == .twentyFourHour {
            hourValue = (normalizedAngle / 360) * 24
        } else {
            
            var hour12 = (normalizedAngle / 360) * 12
            if timeFilter == .pm && hour12 < 12 {
                hour12 += 12
            }
            hourValue = hour12
        }

        var newStartHour = event.startHour
        var newEndHour = event.endHour

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
            let duration = event.endHour - event.startHour
            newStartHour = hourValue - duration / 2
            newEndHour = hourValue + duration / 2

            
            if newStartHour < 0 {
                newStartHour = 0
                newEndHour = duration
            }
            if newEndHour > 24 {
                newEndHour = 24
                newStartHour = 24 - duration
            }
        }


        draggedEventTimes[event.id] = (start: newStartHour, end: newEndHour)


        let currentHour = Int(hourValue)
        if currentHour != lastHapticHour {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
            lastHapticHour = currentHour
        }

        
        
    }

    func handleDragEnded(event: DayEvent) {

        isDraggingStart = false
        isDraggingEnd = false
        isDraggingMiddle = false
        dragStartAngle = 0
        lastHapticHour = -1
        lastInteractionTime = nil

        
        if let finalTimes = draggedEventTimes[event.id],
           let callback = onEventTimeChange {
            callback(event.id, finalTimes.start, finalTimes.end)
        }


        draggedEventTimes.removeValue(forKey: event.id)


        onDragStateChange?(false)

        
        let impactFeedback = UIImpactFeedbackGenerator(style: .rigid)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()

        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            localHighlightedEventId = nil
            selectedArcId = nil
        }
    }

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

                
                let divisor = clockMode == .twentyFourHour ? 24.0 : 12.0
                let startAngle = (highlightedEvent.startHour / divisor) * 360
                let endAngle = (highlightedEvent.endHour / divisor) * 360

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

                
                let hourValue: Double
                if clockMode == .twentyFourHour {
                    hourValue = (normalizedAngle / 360) * 24
                } else {
                    
                    var hour12 = (normalizedAngle / 360) * 12
                    if timeFilter == .pm && hour12 < 12 {
                        hour12 += 12
                    }
                    hourValue = hour12
                }

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
                    let deltaHour = (deltaAngle / 360) * divisor
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
            case .twelveHour:
                
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
            case .twelveHour:
                
                var displayHour = hour

                
                if timeFilter == .am {
                    
                    displayHour = hour > 11 ? hour - 12 : hour
                } else {
                    
                    displayHour = hour >= 12 ? hour - 12 : hour + 12
                }

                
                if displayHour == 0 { displayHour = 12 }
                if displayHour > 12 { displayHour = displayHour - 12 }

                let totalMinutes = displayHour * 60 + minute
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
    
    func eventArc(for event: DayEvent, isHighlighted: Bool = true) -> some View {
        let startAngle: Angle
        let endAngle: Angle

        
        let startHour = draggedEventTimes[event.id]?.start ?? event.startHour
        let endHour = draggedEventTimes[event.id]?.end ?? event.endHour

        switch clockMode {
        case .twentyFourHour:
            
            startAngle = .degrees((startHour / 24) * 360 - 90)
            endAngle = .degrees((endHour / 24) * 360 - 90)

        case .twelveHour:
            
            var adjustedStartHour = startHour
            var adjustedEndHour = endHour

            
            if timeFilter == .am {
                
                if adjustedStartHour >= 12 { adjustedStartHour -= 12 }
                if adjustedEndHour >= 12 { adjustedEndHour -= 12 }
            } else {
                
                if adjustedStartHour >= 12 { adjustedStartHour -= 12 }
                else { adjustedStartHour += 12 }
                if adjustedEndHour >= 12 { adjustedEndHour -= 12 }
                else { adjustedEndHour += 12 }
            }

            
            if adjustedStartHour == 0 { adjustedStartHour = 12 }
            if adjustedStartHour > 12 { adjustedStartHour -= 12 }
            if adjustedEndHour == 0 { adjustedEndHour = 12 }
            if adjustedEndHour > 12 { adjustedEndHour -= 12 }

            startAngle = .degrees((adjustedStartHour / 12) * 360 - 90)
            endAngle = .degrees((adjustedEndHour / 12) * 360 - 90)
        }

        
        let fillOpacity: Double = isHighlighted ? 0.50 : 0.30
        let strokeOpacity: Double = isHighlighted ? 1.0 : 0.8
        let strokeWidth: CGFloat = isHighlighted ? 2.5 : 1.5

        return RadialSegment(startAngle: startAngle, endAngle: endAngle)
            .fill(event.color.opacity(fillOpacity))
            .overlay(
                RadialSegment(startAngle: startAngle, endAngle: endAngle)
                    .stroke(event.color.opacity(strokeOpacity), lineWidth: strokeWidth)
            )
            .frame(width: dialSize, height: dialSize)
            .scaleEffect(isHighlighted ? 1.02 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isHighlighted)
    }
    
    var centerContent: some View {
        VStack(spacing: 8) {
            Text(dayName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            Text(scheduledTimeText)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.7))

            if let event = currentOrUpcomingEvent {
                VStack(spacing: 2) {
                    Text(event.title.uppercased())
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)

                    Text(formatEventTime(event))
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
                DayEvent(title: "Morning Routine", startHour: 6, endHour: 8, color: .purple, category: "Personal",
                        emoji: "☀️", description: "Start the day", participants: [], isCompleted: false),
                DayEvent(title: "Deep Work", startHour: 9, endHour: 13, color: .blue, category: "Work",
                        emoji: "💻", description: "Focus time", participants: [], isCompleted: false),
                DayEvent(title: "Lunch Break", startHour: 13, endHour: 14, color: .green, category: "Break",
                        emoji: "🍔", description: "Lunch time", participants: [], isCompleted: false),
                DayEvent(title: "Meetings", startHour: 14, endHour: 16, color: .orange, category: "Work",
                        emoji: "📅", description: "Team sync", participants: ["John", "Sarah"], isCompleted: false),
                DayEvent(title: "Exercise", startHour: 17, endHour: 18, color: .red, category: "Health",
                        emoji: "🏃", description: "Workout", participants: [], isCompleted: false),
                DayEvent(title: "Dinner", startHour: 19, endHour: 20, color: .yellow, category: "Personal",
                        emoji: "🍽️", description: "Family dinner", participants: [], isCompleted: false),
                DayEvent(title: "Reading", startHour: 21, endHour: 22.5, color: .cyan, category: "Learning",
                        emoji: "📚", description: "Personal development", participants: [], isCompleted: false),
                DayEvent(title: "Sleep", startHour: 23, endHour: 30, color: .indigo, category: "Rest",
                        emoji: "😴", description: "Rest time", participants: [], isCompleted: false)
            ],
            selectedDate: Date()
        )
        .padding()
    }
}
