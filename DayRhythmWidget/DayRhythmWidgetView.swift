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

    var body: some View {
        SmallWidgetView(entry: entry)
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
        .widgetURL(URL(string: "dayrhythm://open"))
    }
}