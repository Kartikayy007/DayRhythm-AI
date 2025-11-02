//
//  DayRhythmWidget.swift
//  DayRhythmWidget
//
//  Created by Kartikay on 02/11/25.
//

import WidgetKit
import SwiftUI

struct DayRhythmWidget: Widget {
    let kind: String = "DayRhythmWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DayRhythmTimelineProvider()) { entry in
            DayRhythmWidgetView(entry: entry)
        }
        .configurationDisplayName("")
        .description("")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

struct DayRhythmWidget_Previews: PreviewProvider {
    static var previews: some View {
        DayRhythmWidgetView(entry: DayRhythmEntry(date: Date(), events: DayRhythmWidget.sampleEvents()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}


extension DayRhythmWidget {
    static func sampleEvents() -> [WidgetEvent] {
        return [
            WidgetEvent(
                id: UUID(),
                title: "Morning Workout",
                startHour: 11.0,
                endHour: 12.0,
                colorHex: "#FF5733",
                emoji: "🏃"
            ),
            WidgetEvent(
                id: UUID(),
                title: "Team Meeting",
                startHour: 10.0,
                endHour: 11.5,
                colorHex: "#33FF57",
                emoji: "👥"
            ),
            WidgetEvent(
                id: UUID(),
                title: "Lunch Break",
                startHour: 12.0,
                endHour: 13.0,
                colorHex: "#3357FF",
                emoji: "🍔"
            ),
            WidgetEvent(
                id: UUID(),
                title: "Focus Work",
                startHour: 14.0,
                endHour: 17.0,
                colorHex: "#F333FF",
                emoji: "💻"
            )
        ]
    }
}
