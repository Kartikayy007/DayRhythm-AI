//
//  HomeViewModel.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {

    @Published var selectedDate: Date = Date()
    @Published var eventsByDate: [String: [DayEvent]] = [:]
    @Published var isSyncing: Bool = false
    @Published var syncError: String?

    
    private let storageManager = StorageManager.shared

    
    private let appState = AppState.shared

    
    @AppStorage("cloudSyncEnabled") private var cloudSyncEnabled: Bool = false

    
    private var cancellables = Set<AnyCancellable>()

    var events: [DayEvent] {
        let dateKey = dateKeyFor(selectedDate)
        return eventsByDate[dateKey] ?? []
    }

    var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: selectedDate)
    }

    var currentTaskId: UUID? {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let currentHour = Double(hour) + Double(minute) / 60.0

        return events.first(where: { event in
            event.startHour <= currentHour && currentHour < event.endHour
        })?.id
    }


    init() {
        loadEvents()
        setupListeners()
    }

    private func setupListeners() {
        
        appState.$isAuthenticated
            .dropFirst() 
            .sink { [weak self] isAuthenticated in
                guard let self = self else { return }

                if isAuthenticated {
                    
                    print("🔐 [HOME VM] User logged in, checking cloud sync...")
                    if self.cloudSyncEnabled {
                        print("🔐 [HOME VM] Cloud sync enabled, fetching tasks from backend...")
                        Task {
                            await self.loadEventsFromCloud()
                        }
                    }
                } else {
                    
                    print("🔐 [HOME VM] User logged out, loading local data only...")
                    self.loadEventsFromLocal()
                }
            }
            .store(in: &cancellables)

        
        NotificationCenter.default.publisher(for: .cloudSyncDidToggle)
            .sink { [weak self] _ in
                guard let self = self else { return }
                print("⚙️ [HOME VM] Cloud sync toggled, reloading events...")
                self.loadEvents()
            }
            .store(in: &cancellables)
    }

    

    func loadEvents() {
        print("📱 [HOME VM] loadEvents() called")
        print("📱 [HOME VM] cloudSyncEnabled: \(cloudSyncEnabled)")

        if cloudSyncEnabled {
            
            print("📱 [HOME VM] Cloud sync enabled, loading from cloud...")
            Task {
                await loadEventsFromCloud()
            }
        } else {
            
            print("📱 [HOME VM] Cloud sync disabled, loading from local only")
            loadEventsFromLocal()
        }
    }

    private func loadEventsFromLocal() {
        print("📱 [HOME VM] Loading events from local storage...")
        eventsByDate = storageManager.loadEventsByDateFromLocal()
        print("📱 [HOME VM] Loaded \(eventsByDate.values.flatMap { $0 }.count) events from local")
        objectWillChange.send()
    }

    
    private func loadEventsFromCloud() async {
        print("📱 [HOME VM] loadEventsFromCloud() called")

        
        await MainActor.run {
            loadEventsFromLocal()
        }

        
        await syncWithCloud()
    }

    

    private func saveEventsToLocal() {
        storageManager.saveEventsByDateLocally(eventsByDate)
    }

    func dateKeyFor(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current  
        return formatter.string(from: date)
    }

    func addEvent(_ event: DayEvent, for date: Date? = nil, repeatDaily: Bool = false) {
        print("📱 [HOME VM] addEvent() called")
        print("📱 [HOME VM] Event: \(event.title)")
        print("📱 [HOME VM] cloudSyncEnabled: \(cloudSyncEnabled)")

        
        let targetDate = date ?? selectedDate

        
        let modifiedEvent = DayEvent(
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
            syncStatus: cloudSyncEnabled ? .pending : .local,
            lastModified: Date(),
            dateString: dateKeyFor(targetDate)
        )

        if repeatDaily {
            for dayOffset in 0..<30 {
                if let repeatDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: targetDate) {
                    let dateKey = dateKeyFor(repeatDate)
                    
                    let dailyEvent = DayEvent(
                        id: UUID(),  
                        title: modifiedEvent.title,
                        startHour: modifiedEvent.startHour,
                        endHour: modifiedEvent.endHour,
                        color: modifiedEvent.color,
                        category: modifiedEvent.category,
                        emoji: modifiedEvent.emoji,
                        description: modifiedEvent.description,
                        participants: modifiedEvent.participants,
                        isCompleted: modifiedEvent.isCompleted,
                        notificationSettings: modifiedEvent.notificationSettings,
                        cloudId: nil,  
                        syncStatus: modifiedEvent.syncStatus,
                        lastModified: modifiedEvent.lastModified,
                        dateString: dateKey
                    )

                    if eventsByDate[dateKey] != nil {
                        eventsByDate[dateKey]?.append(dailyEvent)
                    } else {
                        eventsByDate[dateKey] = [dailyEvent]
                    }
                }
            }
        } else {
            let dateKey = dateKeyFor(targetDate)
            if eventsByDate[dateKey] != nil {
                eventsByDate[dateKey]?.append(modifiedEvent)
            } else {
                eventsByDate[dateKey] = [modifiedEvent]
            }
        }

        
        saveEventsToLocal()

        
        if cloudSyncEnabled {
            print("📱 [HOME VM] Syncing new event to cloud...")
            Task {
                await syncEventToCloud(modifiedEvent)
            }
        } else {
            print("📱 [HOME VM] Cloud sync disabled, skipping cloud sync")
        }

        objectWillChange.send()
    }

    func selectDate(_ date: Date) {
        selectedDate = date
    }

    func moveToNextDay() {
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            selectedDate = nextDay
        }
    }

    func moveToPreviousDay() {
        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = previousDay
        }
    }

    func deleteEvent(_ event: DayEvent) {
        let dateKey = dateKeyFor(selectedDate)
        eventsByDate[dateKey]?.removeAll { $0.id == event.id }

        
        Task {
            await NotificationService.shared.cancelAllNotifications(for: event.id)
        }

        
        saveEventsToLocal()

        
        if cloudSyncEnabled {
            Task {
                await deleteEventFromCloud(event)
            }
        }

        objectWillChange.send()
    }

    func updateEvent(_ oldEvent: DayEvent, with newEvent: DayEvent, for date: Date? = nil) {
        
        let targetDate = date ?? selectedDate
        let newDateKey = dateKeyFor(targetDate)

        
        let oldDateKey = oldEvent.dateString.isEmpty ? dateKeyFor(selectedDate) : oldEvent.dateString

        
        if oldDateKey != newDateKey {
            
            eventsByDate[oldDateKey]?.removeAll { $0.id == oldEvent.id }
            if eventsByDate[oldDateKey]?.isEmpty == true {
                eventsByDate.removeValue(forKey: oldDateKey)
            }
        }

        
        if let index = eventsByDate[newDateKey]?.firstIndex(where: { $0.id == oldEvent.id }) {
            
            let modifiedEvent = DayEvent(
                id: newEvent.id,
                title: newEvent.title,
                startHour: newEvent.startHour,
                endHour: newEvent.endHour,
                color: newEvent.color,
                category: newEvent.category,
                emoji: newEvent.emoji,
                description: newEvent.description,
                participants: newEvent.participants,
                isCompleted: newEvent.isCompleted,
                notificationSettings: newEvent.notificationSettings,
                cloudId: oldEvent.cloudId ?? newEvent.cloudId,  
                syncStatus: cloudSyncEnabled ? .pending : .local,
                lastModified: Date(),
                dateString: newDateKey
            )

            eventsByDate[newDateKey]?[index] = modifiedEvent
        } else {
            
            let modifiedEvent = DayEvent(
                id: newEvent.id,
                title: newEvent.title,
                startHour: newEvent.startHour,
                endHour: newEvent.endHour,
                color: newEvent.color,
                category: newEvent.category,
                emoji: newEvent.emoji,
                description: newEvent.description,
                participants: newEvent.participants,
                isCompleted: newEvent.isCompleted,
                notificationSettings: newEvent.notificationSettings,
                cloudId: oldEvent.cloudId ?? newEvent.cloudId,
                syncStatus: cloudSyncEnabled ? .pending : .local,
                lastModified: Date(),
                dateString: newDateKey
            )

            if eventsByDate[newDateKey] != nil {
                eventsByDate[newDateKey]?.append(modifiedEvent)
            } else {
                eventsByDate[newDateKey] = [modifiedEvent]
            }
        }

        
        saveEventsToLocal()

        
        if cloudSyncEnabled {
            
            let dateKey = dateKeyFor(targetDate)
            if let updatedEvent = eventsByDate[dateKey]?.first(where: { $0.id == newEvent.id }) {
                Task {
                    await updateEventInCloud(updatedEvent)
                }
            }
        }

        objectWillChange.send()
    }

    

    
    private func syncEventToCloud(_ event: DayEvent) async {
        print("📱 [HOME VM] syncEventToCloud() called for: \(event.title)")

        do {
            let syncedEvent = try await CloudSyncService.shared.saveEvent(event)
            
            await MainActor.run {
                let dateKey = event.dateString
                if let index = eventsByDate[dateKey]?.firstIndex(where: { $0.id == event.id }) {
                    eventsByDate[dateKey]?[index] = syncedEvent
                    saveEventsToLocal()
                    objectWillChange.send()
                    print("📱 [HOME VM] Event synced and updated locally with cloudId: \(syncedEvent.cloudId ?? "nil")")
                }
            }
        } catch {
            print("❌ [HOME VM] Failed to sync event to cloud: \(error)")
            
        }
    }

    
    private func updateEventInCloud(_ event: DayEvent) async {
        print("📱 [HOME VM] updateEventInCloud() called for: \(event.title)")

        do {
            let syncedEvent = try await CloudSyncService.shared.updateEvent(event)
            
            await MainActor.run {
                let dateKey = event.dateString
                if let index = eventsByDate[dateKey]?.firstIndex(where: { $0.id == event.id }) {
                    eventsByDate[dateKey]?[index] = syncedEvent
                    saveEventsToLocal()
                    objectWillChange.send()
                    print("📱 [HOME VM] Event updated in cloud successfully")
                }
            }
        } catch {
            print("❌ [HOME VM] Failed to update event in cloud: \(error)")
            
        }
    }

    
    private func deleteEventFromCloud(_ event: DayEvent) async {
        print("📱 [HOME VM] deleteEventFromCloud() called for: \(event.title)")

        do {
            try await CloudSyncService.shared.deleteEvent(event)
            print("✅ [HOME VM] Successfully deleted event from cloud")
        } catch {
            print("❌ [HOME VM] Failed to delete event from cloud: \(error)")
            
        }
    }

    func syncWithCloud() async {
        print("📱 [HOME VM] syncWithCloud() called")
        print("📱 [HOME VM] cloudSyncEnabled: \(cloudSyncEnabled)")

        guard cloudSyncEnabled else {
            print("📱 [HOME VM] Cloud sync disabled, skipping")
            return
        }

        await MainActor.run {
            isSyncing = true
            syncError = nil
        }

        print("📱 [HOME VM] Starting full sync...")

        do {
            
            let localEvents = eventsByDate.values.flatMap { $0 }
            print("📱 [HOME VM] Local events to sync: \(localEvents.count)")

            
            let syncedEvents = try await CloudSyncService.shared.performFullSync(localEvents: localEvents)
            print("📱 [HOME VM] Full sync completed, synced events: \(syncedEvents.count)")

            
            var newEventsByDate: [String: [DayEvent]] = [:]
            for event in syncedEvents {
                let dateKey = event.dateString
                if newEventsByDate[dateKey] == nil {
                    newEventsByDate[dateKey] = []
                }
                newEventsByDate[dateKey]?.append(event)
            }

            
            for (key, value) in newEventsByDate {
                newEventsByDate[key] = value.sorted { $0.startHour < $1.startHour }
            }

            await MainActor.run {
                eventsByDate = newEventsByDate
                isSyncing = false
                objectWillChange.send()
            }
        } catch {
            await MainActor.run {
                syncError = error.localizedDescription
                isSyncing = false
                print("Sync failed: \(error)")
            }
        }
    }
}
