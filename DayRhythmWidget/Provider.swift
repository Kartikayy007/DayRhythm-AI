//
//  Provider.swift
//  DayRhythmWidget
//
//  Created by Kartikay on 02/11/25.
//

import WidgetKit
import SwiftUI

struct DayRhythmTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> DayRhythmEntry {
        DayRhythmEntry(date: Date(), events: DayRhythmWidget.sampleEvents())
    }

    func getSnapshot(in context: Context, completion: @escaping (DayRhythmEntry) -> ()) {
        let entry = DayRhythmEntry(date: Date(), events: loadEvents())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DayRhythmEntry>) -> ()) {
        var entries: [DayRhythmEntry] = []

        
        let currentDate = Date()
        let events = loadEvents()

        for minuteOffset in stride(from: 0, to: 60, by: 15) {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = DayRhythmEntry(date: entryDate, events: events)
            entries.append(entry)
        }

        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    
    private func loadEvents() -> [WidgetEvent] {
        
        let sharedDefaults = UserDefaults(suiteName: "group.kartikay.DayRhythm-AI")

        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        let dateKey = formatter.string(from: Date())

        
        if let data = sharedDefaults?.data(forKey: "widget_events_\(dateKey)") {
            do {
                
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    let events = jsonArray.compactMap { dict -> WidgetEvent? in
                        guard let idString = dict["id"] as? String,
                              let id = UUID(uuidString: idString),
                              let title = dict["title"] as? String,
                              let startHour = dict["startHour"] as? Double,
                              let endHour = dict["endHour"] as? Double,
                              let colorHex = dict["colorHex"] as? String,
                              let emoji = dict["emoji"] as? String else {
                            return nil
                        }

                        return WidgetEvent(
                            id: id,
                            title: title,
                            startHour: startHour,
                            endHour: endHour,
                            colorHex: colorHex,
                            emoji: emoji
                        )
                    }
                    if !events.isEmpty {
                        return events
                    }
                }


                let events = try JSONDecoder().decode([WidgetEvent].self, from: data)
                return events
            } catch {
                print("Widget: Failed to decode events: \(error)")
            }
        }


        return []
    }
}

struct DayRhythmEntry: TimelineEntry {
    let date: Date
    let events: [WidgetEvent]

    var currentHour: Double {
        let calendar = Calendar.current
        let hour = Double(calendar.component(.hour, from: date))
        let minute = Double(calendar.component(.minute, from: date))
        return hour + (minute / 60.0)
    }

    var currentEvent: WidgetEvent? {
        return events.first(where: { event in
            event.startHour <= currentHour && currentHour < event.endHour
        })
    }

    var upcomingEvent: WidgetEvent? {
        return events.first(where: { event in
            event.startHour > currentHour
        })
    }

    var remainingEventsCount: Int {
        return events.filter { $0.startHour > currentHour }.count
    }
}