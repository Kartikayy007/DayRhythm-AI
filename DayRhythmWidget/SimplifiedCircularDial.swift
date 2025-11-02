//
//  SimplifiedCircularDial.swift
//  DayRhythmWidget
//
//  Created by Kartikay on 02/11/25.
//

import SwiftUI


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

struct SimplifiedCircularDial: View {
    let events: [WidgetEvent]
    let currentTime: Date
    let size: CGFloat
    let showLabels: Bool

    private let strokeWidth: CGFloat = 1
    private let tickLength: CGFloat = 4
    private let majorTickLength: CGFloat = 8

    
    private var isAM: Bool {
        let hour = Calendar.current.component(.hour, from: currentTime)
        return hour < 12
    }

    private var currentHour: Double {
        let calendar = Calendar.current
        let hour = Double(calendar.component(.hour, from: currentTime))
        let minute = Double(calendar.component(.minute, from: currentTime))
        let second = Double(calendar.component(.second, from: currentTime))
        let nanosecond = Double(calendar.component(.nanosecond, from: currentTime))
        return hour + minute / 60.0 + second / 3600.0 + Double(nanosecond) / (3600.0 * 1_000_000_000)
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

    var body: some View {
        ZStack {
            
            hourMarkers

            
            ForEach(events, id: \.id) { event in
                eventArc(for: event)
            }

            
            currentTimeIndicator

            
            if size >= 120 && showLabels {
                centerContent
            }
        }
        .frame(width: size, height: size)
    }

    var hourMarkers: some View {
        ZStack {
            
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: strokeWidth)

            
            ForEach(0..<60) { index in
                tick(at: index)
            }

            
            if showLabels {
                ForEach([12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], id: \.self) { hour in
                    let angle = hour == 12 ? 0 : Double(hour) * 30
                    hourNumber("\(hour)", angle: angle)
                }
            }
        }
    }

    func tick(at index: Int) -> some View {
        let isMajor = index % 5 == 0
        let length = isMajor ? majorTickLength : tickLength
        let width: CGFloat = isMajor ? 1.5 : 0.5

        return Rectangle()
            .fill(Color.white.opacity(isMajor ? 0.6 : 0.3))
            .frame(width: width, height: length * (size / 320))
            .offset(y: -size / 2 + (length * (size / 320)) / 2)
            .rotationEffect(.degrees(Double(index) * 6))
    }

    func hourNumber(_ text: String, angle: Double) -> some View {
        let radians = (angle - 90) * .pi / 180
        let offset = size / 2 - (size * 0.15)
        let x = cos(radians) * offset
        let y = sin(radians) * offset

        return Text(text)
            .font(.system(size: size * 0.05, weight: .medium))
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

        
        let hour12 = hour.truncatingRemainder(dividingBy: 12)
        let hourAngle = ((hour12 * 60 + minute) / (12 * 60)) * 360

        return ZStack {
            
            Rectangle()
                .fill(Color.cyan)
                .frame(width: size * 0.01, height: size * 0.25)
                .offset(y: -size * 0.125)
                .rotationEffect(.degrees(hourAngle), anchor: .center)

            
            Rectangle()
                .fill(Color.cyan.opacity(0.8))
                .frame(width: size * 0.008, height: size * 0.35)
                .offset(y: -size * 0.175)
                .rotationEffect(.degrees(minuteAngle), anchor: .center)

            
            if size > 150 {
                Rectangle()
                    .fill(Color.cyan.opacity(0.6))
                    .frame(width: size * 0.004, height: size * 0.4)
                    .offset(y: -size * 0.2)
                    .rotationEffect(.degrees(secondAngle), anchor: .center)
            }

            
            Circle()
                .fill(Color.cyan)
                .frame(width: size * 0.025, height: size * 0.025)
        }
    }

    @ViewBuilder
    func eventArc(for event: WidgetEvent) -> some View {
        
        let hourRange = isAM ? 0.0...11.99 : 12.0...23.99

        
        if event.startHour < hourRange.upperBound && event.endHour > hourRange.lowerBound {
            
            let clampedStart = max(event.startHour, hourRange.lowerBound)
            let clampedEnd = min(event.endHour, hourRange.upperBound)

            
            let adjustedStartHour = clampedStart.truncatingRemainder(dividingBy: 12)
            let adjustedEndHour = clampedEnd.truncatingRemainder(dividingBy: 12)

            let startAngle = Angle(degrees: (adjustedStartHour / 12) * 360 - 90)
            let endAngle = Angle(degrees: (adjustedEndHour / 12) * 360 - 90)

            
            let scaledInnerRadius = 40 * (size / 320)

            ZStack {
                RadialSegmentWidget(
                    startAngle: startAngle,
                    endAngle: endAngle,
                    innerRadius: scaledInnerRadius
                )
                .fill(event.color.opacity(0.3))
                .frame(width: size, height: size)

                RadialSegmentWidget(
                    startAngle: startAngle,
                    endAngle: endAngle,
                    innerRadius: scaledInnerRadius
                )
                .stroke(event.color.opacity(0.8), lineWidth: 1.5)
                .frame(width: size, height: size)
            }
        }
    }

    var centerContent: some View {
        VStack(spacing: 2) {
            
            Text(dayName)
                .font(.system(size: size * 0.08, weight: .bold))
                .foregroundColor(.white)

            
            Text(isAM ? "AM" : "PM")
                .font(.system(size: size * 0.06, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))

            
            if !events.isEmpty {
                let filteredCount = events.filter { event in
                    let hourRange = isAM ? 0.0...11.99 : 12.0...23.99
                    return event.startHour < hourRange.upperBound && event.endHour > hourRange.lowerBound
                }.count
                if filteredCount > 0 {
                    Text("\(filteredCount) events")
                        .font(.system(size: size * 0.04, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }

    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: currentTime).uppercased()
    }
}


struct RadialSegmentWidget: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let innerRadius: CGFloat

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