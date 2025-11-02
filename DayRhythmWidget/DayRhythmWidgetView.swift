//
//  DayRhythmWidgetView.swift
//  DayRhythmWidget
//
//  Created by Kartikay on 02/11/25.
//

import SwiftUI
import WidgetKit

struct DayRhythmWidgetView: View {
    var entry: DayRhythmTimelineProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .systemExtraLarge:
            LargeWidgetView(entry: entry)
        case .accessoryCircular:
            EmptyView()
        case .accessoryRectangular:
            EmptyView()
        case .accessoryInline:
            EmptyView()
        @unknown default:
            SmallWidgetView(entry: entry)
        }
    }
}


struct SmallWidgetView: View {
    let entry: DayRhythmTimelineProvider.Entry

    var body: some View {
        SimplifiedCircularDial(
            events: entry.events,
            currentTime: entry.date,
            size: 155,
            showLabels: true
        )
        .containerBackground(Color.black, for: .widget)
        .widgetURL(URL(string: "dayrhythm:
    }
}


struct MediumWidgetView: View {
    let entry: DayRhythmTimelineProvider.Entry

    var body: some View {
        HStack(spacing: 6) {
            
            SimplifiedCircularDial(
                events: entry.events,
                currentTime: entry.date,
                size: 110,
                showLabels: false
            )
            .frame(width: 110, height: 110)

            
            VStack(alignment: .leading, spacing: 4) {
                let hour = Calendar.current.component(.hour, from: entry.date)
                let isAM = hour < 12
                let filteredEvents = entry.events.filter { event in
                    let hourRange = isAM ? 0.0...11.99 : 12.0...23.99
                    return event.startHour < hourRange.upperBound && event.endHour > hourRange.lowerBound
                }

                if !filteredEvents.isEmpty {
                    
                    ForEach(Array(filteredEvents.prefix(3)), id: \.id) { event in
                        HStack(spacing: 4) {
                            Text(event.emoji)
                                .font(.system(size: 15))

                            Text(event.title)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .truncationMode(.tail)

                            Spacer(minLength: 0)

                            if event.id == entry.currentEvent?.id {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 5, height: 5)
                            }
                        }
                    }
                } else {
                    Text("No events")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer(minLength: 0)
            }

            Spacer(minLength: 0)
        }
        .padding(6)
        .containerBackground(Color.black, for: .widget)
        .widgetURL(URL(string: "dayrhythm:
    }
}


struct LargeWidgetView: View {
    let entry: DayRhythmTimelineProvider.Entry

    private func formatTime(_ hour: Double) -> String {
        let h = Int(hour)
        let m = Int((hour - Double(h)) * 60)
        let period = h >= 12 ? "PM" : "AM"
        let displayHour = h > 12 ? h - 12 : (h == 0 ? 12 : h)

        if m == 0 {
            return "\(displayHour):00 \(period)"
        } else {
            return String(format: "%d:%02d %@", displayHour, m, period)
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            
            HStack {
                Text(getDayName())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Text(entry.date, style: .date)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 4)

            
            SimplifiedCircularDial(
                events: entry.events,
                currentTime: entry.date,
                size: 150,  
                showLabels: true
            )
            .frame(width: 150, height: 150)

            
            let hour = Calendar.current.component(.hour, from: entry.date)
            let isAM = hour < 12
            let filteredEvents = entry.events.filter { event in
                let hourRange = isAM ? 0.0...11.99 : 12.0...23.99
                return event.startHour < hourRange.upperBound && event.endHour > hourRange.lowerBound
            }

            if !filteredEvents.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    
                    ForEach(Array(filteredEvents.prefix(4)), id: \.id) { event in
                        HStack(spacing: 8) {
                            
                            Text(formatTime(event.startHour))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .frame(width: 65, alignment: .leading)

                            
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(event.color)
                                .frame(width: 2, height: 18)

                            
                            Text(event.emoji)
                                .font(.system(size: 15))

                            
                            Text(event.title)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .truncationMode(.tail)

                            Spacer(minLength: 0)

                            
                            if event.id == entry.currentEvent?.id {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 4)
            } else {
                Text("No events")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer(minLength: 0)
        }
        .padding(8)
        .containerBackground(Color.black, for: .widget)
        .widgetURL(URL(string: "dayrhythm:
    }

    private func getDayName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: entry.date).uppercased()
    }
}