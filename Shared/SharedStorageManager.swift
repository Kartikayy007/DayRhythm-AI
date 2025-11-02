//
//  SharedStorageManager.swift
//  DayRhythm AI
//
//  Created by Kartikay on 02/11/25.
//

import Foundation


class SharedStorageManager {
    static let shared = SharedStorageManager()

    
    private let appGroupIdentifier = "group.kartikay.DayRhythm-AI"

    private var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }

    private init() {}

    func saveEventsForWidget(_ events: [DayEvent], for date: Date) {
        guard let sharedDefaults = sharedDefaults else { return }

        
        let widgetEvents = events.map { event in
            return WidgetEventData(
                id: event.id,
                title: event.title,
                startHour: event.startHour,
                endHour: event.endHour,
                colorHex: event.colorHex,
                emoji: event.emoji
            )
        }

        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        let dateKey = formatter.string(from: date)

        
        if let data = try? JSONEncoder().encode(widgetEvents) {
            sharedDefaults.set(data, forKey: "widget_events_\(dateKey)")
            sharedDefaults.set(Date(), forKey: "widget_last_update")
            notifyWidgetToRefresh()
        }
    }

    
    func loadWidgetEvents(for date: Date) -> [WidgetEventData]? {
        guard let sharedDefaults = sharedDefaults else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        let dateKey = formatter.string(from: date)

        if let data = sharedDefaults.data(forKey: "widget_events_\(dateKey)"),
           let events = try? JSONDecoder().decode([WidgetEventData].self, from: data) {
            return events
        }

        return nil
    }

    
    func cleanupOldWidgetData() {
        guard let sharedDefaults = sharedDefaults else { return }

        let calendar = Calendar.current
        let today = Date()

        
        for dayOffset in -30...<(-7) {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: today) {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.timeZone = TimeZone.current
                let dateKey = formatter.string(from: date)

                sharedDefaults.removeObject(forKey: "widget_events_\(dateKey)")
            }
        }
    }

    

    
    func saveWidgetConfiguration(use24Hour: Bool, colorTheme: String) {
        guard let sharedDefaults = sharedDefaults else { return }

        sharedDefaults.set(use24Hour, forKey: "widget_use_24_hour")
        sharedDefaults.set(colorTheme, forKey: "widget_color_theme")
    }

    
    func loadWidgetConfiguration() -> (use24Hour: Bool, colorTheme: String) {
        guard let sharedDefaults = sharedDefaults else {
            return (use24Hour: false, colorTheme: "default")
        }

        let use24Hour = sharedDefaults.bool(forKey: "widget_use_24_hour")
        let colorTheme = sharedDefaults.string(forKey: "widget_color_theme") ?? "default"

        return (use24Hour: use24Hour, colorTheme: colorTheme)
    }

    

    
    private func notifyWidgetToRefresh() {
        #if os(iOS)
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
        #endif
    }
}


struct WidgetEventData: Codable {
    let id: UUID
    let title: String
    let startHour: Double
    let endHour: Double
    let colorHex: String
    let emoji: String
}