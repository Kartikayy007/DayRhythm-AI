//
//  CircularDayDial.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI


struct CircularDayDial: View {
    let events: [DayEvent]
    let selectedDate: Date
    
    
    @StateObject private var motionManager = MotionManager()
    
    
    private let dialSize: CGFloat = 320
    private let strokeWidth: CGFloat = 2
    private let tickLength: CGFloat = 8
    private let majorTickLength: CGFloat = 15
    private let arcWidth: CGFloat = 30
    
    
    private var totalScheduledHours: Double {
        events.reduce(0) { $0 + $1.duration }
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
        ZStack {
            // Outer circle with hour markers
            hourMarkers
            
            // Event arcs
            ForEach(events) { event in
                eventArc(for: event)
            }
            
            // Center content
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


private extension CircularDayDial {
    
    var hourMarkers: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: strokeWidth)
            
            ForEach(0..<60) { index in
                tick(at: index)
            }
            
            // Hour numbers (12, 3, 6, 9)
            hourNumber(12, angle: -90)
            hourNumber(3, angle: 0)
            hourNumber(6, angle: 90)
            hourNumber(9, angle: 180)
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
    
    
    func hourNumber(_ hour: Int, angle: Double) -> some View {
        Text("\(hour)")
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(.white.opacity(0.8))
            .offset(y: -dialSize / 2 + 40)
            .rotationEffect(.degrees(angle))
    }
    
    
    func eventArc(for event: DayEvent) -> some View {
        EventArc(
            startHour: event.startHour,
            duration: event.duration,
            color: event.color,
            radius: dialSize / 2 - arcWidth / 2,
            lineWidth: arcWidth
        )
    }
    
    
    var centerContent: some View {
        VStack(spacing: 8) {
            Text(dayName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(scheduledTimeText)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
            
            if let firstEvent = events.first {
                VStack(spacing: 2) {
                    Text(firstEvent.title.uppercased())
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(firstEvent.color)
                    
                    Text(formatEventTime(firstEvent))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white)
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


struct EventArc: View {
    let startHour: Double
    let duration: Double
    let color: Color
    let radius: CGFloat
    let lineWidth: CGFloat
    
    private var startAngle: Angle {
        // Convert hour to angle (12 o'clock = -90°)
        .degrees((startHour / 24) * 360 - 90)
    }
    
    private var endAngle: Angle {
        .degrees(((startHour + duration) / 24) * 360 - 90)
    }
    
    var body: some View {
        Circle()
            .trim(from: startHour / 24, to: (startHour + duration) / 24)
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .frame(width: radius * 2, height: radius * 2)
            .rotationEffect(.degrees(-90))
    }
}


#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        CircularDayDial(
            events: [
                DayEvent(title: "Morning Routine", startHour: 6, duration: 3, color: .orange),
                DayEvent(title: "Focus", startHour: 10, duration: 5, color: .green)
            ],
            selectedDate: Date()
        )
    }
}
