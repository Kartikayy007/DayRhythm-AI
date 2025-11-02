//
//  StorageManager.swift
//  DayRhythm AI
//
//  Created by Kartikay on 01/11/25.
//

import Foundation
import SwiftUI



class StorageManager {
    static let shared = StorageManager()
    private let userDefaults = UserDefaults.standard

    
    private let eventsKey = "com.dayrhythm.events"
    private let lastSyncDateKey = "com.dayrhythm.lastSyncDate"
    private let cloudSyncEnabledKey = "com.dayrhythm.cloudSyncEnabled"

    private init() {}

    

    
    var isCloudSyncEnabled: Bool {
        get {
            userDefaults.bool(forKey: cloudSyncEnabledKey)
        }
        set {
            userDefaults.set(newValue, forKey: cloudSyncEnabledKey)
            userDefaults.synchronize()
        }
    }

    
    var lastSyncDate: Date? {
        get {
            userDefaults.object(forKey: lastSyncDateKey) as? Date
        }
        set {
            userDefaults.set(newValue, forKey: lastSyncDateKey)
            userDefaults.synchronize()
        }
    }

    

    
    func saveEventsLocally(_ events: [DayEvent]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601

            let eventData = try encoder.encode(events)
            userDefaults.set(eventData, forKey: eventsKey)
            userDefaults.synchronize()

            print("✅ Successfully saved \(events.count) events locally")
        } catch {
            print("❌ Failed to save events locally: \(error.localizedDescription)")
        }
    }

    
    func saveEventsByDateLocally(_ eventsByDate: [String: [DayEvent]]) {
        
        let allEvents = eventsByDate.values.flatMap { $0 }
        saveEventsLocally(allEvents)
    }

    
    func loadEventsFromLocal() -> [DayEvent] {
        guard let eventData = userDefaults.data(forKey: eventsKey) else {
            print("ℹ️ No local events found")
            return []
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let events = try decoder.decode([DayEvent].self, from: eventData)
            print("✅ Successfully loaded \(events.count) events from local storage")
            return events
        } catch {
            print("❌ Failed to load events from local storage: \(error.localizedDescription)")
            return []
        }
    }

    
    func loadEventsByDateFromLocal() -> [String: [DayEvent]] {
        let events = loadEventsFromLocal()

        
        var eventsByDate: [String: [DayEvent]] = [:]

        for event in events {
            let dateKey = event.dateString
            if eventsByDate[dateKey] == nil {
                eventsByDate[dateKey] = []
            }
            eventsByDate[dateKey]?.append(event)
        }

        
        for (key, value) in eventsByDate {
            eventsByDate[key] = value.sorted { $0.startHour < $1.startHour }
        }

        return eventsByDate
    }

    
    func clearLocalEvents() {
        userDefaults.removeObject(forKey: eventsKey)
        userDefaults.synchronize()
        print("✅ Cleared all local events")
    }

    

    
    
    func prepareEventsForCloudMigration(_ events: [DayEvent]) -> [DayEvent] {
        return events.map { event in
            DayEvent(
                id: event.id,
                title: event.title,
                startHour: event.startHour,
                endHour: event.endHour,
                color: event.color,
                category: event.category,
                emoji: event.emoji,
                description: event.description,
                participants: event.participants,
                isCompleted: event.isCompleted,
                notificationSettings: event.notificationSettings,
                cloudId: event.cloudId,
                syncStatus: .pending,
                lastModified: Date(),
                dateString: event.dateString
            )
        }
    }

    
    
    func prepareEventsForLocalMigration(_ events: [DayEvent]) -> [DayEvent] {
        return events.map { event in
            DayEvent(
                id: event.id,
                title: event.title,
                startHour: event.startHour,
                endHour: event.endHour,
                color: event.color,
                category: event.category,
                emoji: event.emoji,
                description: event.description,
                participants: event.participants,
                isCompleted: event.isCompleted,
                notificationSettings: event.notificationSettings,
                cloudId: event.cloudId,  
                syncStatus: .local,
                lastModified: Date(),
                dateString: event.dateString
            )
        }
    }

    
    func migrateToCloud(_ events: [DayEvent], completion: @escaping (Bool, [DayEvent]) -> Void) {
        let preparedEvents = prepareEventsForCloudMigration(events)

        
        
        completion(true, preparedEvents)
    }

    
    func migrateToLocal(_ events: [DayEvent]) {
        let preparedEvents = prepareEventsForLocalMigration(events)
        saveEventsLocally(preparedEvents)

        
        lastSyncDate = Date()
    }

    

    
    
    func resolveConflicts(localEvents: [DayEvent], cloudEvents: [DayEvent]) -> [DayEvent] {
        var resolvedEvents: [DayEvent] = []
        var processedCloudIds: Set<String> = []
        var processedLocalIds: Set<UUID> = []

        
        
        var localByCloudId: [String: DayEvent] = [:]
        for event in localEvents {
            if let cloudId = event.cloudId {
                localByCloudId[cloudId] = event
            }
        }

        
        func eventKey(_ event: DayEvent) -> String {
            
            return "\(event.title)|\(event.startHour)|\(event.endHour)|\(event.dateString)"
        }

        var localByContent: [String: DayEvent] = [:]
        for event in localEvents {
            localByContent[eventKey(event)] = event
        }

        
        for cloudEvent in cloudEvents {
            var matchedLocalEvent: DayEvent? = nil

            
            if let cloudId = cloudEvent.cloudId {
                matchedLocalEvent = localByCloudId[cloudId]
                if matchedLocalEvent != nil {
                    processedCloudIds.insert(cloudId)
                }
            }

            
            if matchedLocalEvent == nil {
                let contentKey = eventKey(cloudEvent)
                matchedLocalEvent = localByContent[contentKey]
            }

            if let localEvent = matchedLocalEvent {
                
                if let cloudModified = cloudEvent.lastModified,
                   let localModified = localEvent.lastModified {
                    resolvedEvents.append(cloudModified > localModified ? cloudEvent : localEvent)
                } else {
                    
                    resolvedEvents.append(cloudEvent)
                }
                processedLocalIds.insert(localEvent.id)
            } else {
                
                resolvedEvents.append(cloudEvent)
            }
            processedLocalIds.insert(cloudEvent.id)
        }

        
        for localEvent in localEvents {
            
            if processedLocalIds.contains(localEvent.id) {
                continue
            }
            
            if let cloudId = localEvent.cloudId, processedCloudIds.contains(cloudId) {
                continue
            }
            
            resolvedEvents.append(localEvent)
        }

        return resolvedEvents
    }

    

    
    func getLocalStorageSize() -> Int {
        guard let eventData = userDefaults.data(forKey: eventsKey) else {
            return 0
        }
        return eventData.count
    }

    
    func getFormattedStorageSize() -> String {
        let bytes = getLocalStorageSize()
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(bytes))
    }

    
    func hasLocalEvents() -> Bool {
        return !loadEventsFromLocal().isEmpty
    }
}