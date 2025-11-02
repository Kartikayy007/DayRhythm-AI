//
//  HomeViewModel.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI
import Combine
import EventKit

final class HomeViewModel: ObservableObject {

    @Published var selectedDate: Date = Date()
    @Published var eventsByDate: [String: [DayEvent]] = [:]
    @Published var isSyncing: Bool = false
    @Published var syncError: String?
    @Published var calendarEvents: [DayEvent] = []  


    private let storageManager = StorageManager.shared


    private let appState = AppState.shared

    
    private let eventKitService = EventKitService.shared


    @AppStorage("cloudSyncEnabled") private var cloudSyncEnabled: Bool = false
    @AppStorage("calendarSyncEnabled") private var calendarSyncEnabled: Bool = false


    private var cancellables = Set<AnyCancellable>()

    var events: [DayEvent] {
        let dateKey = dateKeyFor(selectedDate)
        let localEvents = eventsByDate[dateKey] ?? []

        
        let allEvents = localEvents + calendarEvents
        return allEvents.sorted { $0.startHour < $1.startHour }
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
                    
                    
                    if self.cloudSyncEnabled {
                        
                        Task {
                            await self.loadEventsFromCloud()
                        }
                    }
                } else {
                    
                    
                    self.loadEventsFromLocal()
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .cloudSyncDidToggle)
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                self.loadEvents()
            }
            .store(in: &cancellables)

        
        NotificationCenter.default.publisher(for: .calendarSyncRequested)
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                Task {
                    await self.loadCalendarEvents()
                }
            }
            .store(in: &cancellables)

        
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .compactMap { _ in UserDefaults.standard.object(forKey: "calendarSyncEnabled") as? Bool }
            .removeDuplicates()
            .sink { [weak self] enabled in
                guard let self = self else { return }
                
                if enabled {
                    Task {
                        await self.loadCalendarEvents()
                    }
                } else {
                    
                    Task { @MainActor in
                        self.calendarEvents = []
                        self.objectWillChange.send()
                    }
                }
            }
            .store(in: &cancellables)

        
        $selectedDate
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.calendarSyncEnabled {
                    Task {
                        await self.loadCalendarEvents()
                    }
                }
            }
            .store(in: &cancellables)

        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                self.loadEvents()
            }
            .store(in: &cancellables)

        
        NotificationCenter.default.publisher(for: .calendarDataChanged)
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.calendarSyncEnabled {
                    Task {
                        await self.loadCalendarEvents()
                    }
                }
            }
            .store(in: &cancellables)
    }

    

    func loadEvents() {
        
        
        

        if cloudSyncEnabled {

            
            Task {
                await loadEventsFromCloud()
            }
        } else {

            
            loadEventsFromLocal()
        }

        
        if calendarSyncEnabled {
            
            Task {
                await loadCalendarEvents()
            }
        }
    }

    private func loadEventsFromLocal() {
        
        eventsByDate = storageManager.loadEventsByDateFromLocal()
        
        objectWillChange.send()
    }

    
    private func loadEventsFromCloud() async {
        

        
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
            
            Task {
                await syncEventToCloud(modifiedEvent)
            }
        } else {
            
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

        
        if event.isFromCalendar && calendarSyncEnabled {
            Task {
                await deleteEventFromCalendar(event)
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
                dateString: newDateKey,
                ekEventIdentifier: oldEvent.ekEventIdentifier ?? newEvent.ekEventIdentifier,
                ekCalendarIdentifier: oldEvent.ekCalendarIdentifier ?? newEvent.ekCalendarIdentifier,
                isFromCalendar: oldEvent.isFromCalendar || newEvent.isFromCalendar
            )

            eventsByDate[newDateKey]?[index] = modifiedEvent

            
            if modifiedEvent.isFromCalendar && calendarSyncEnabled {
                Task {
                    await syncEventToCalendar(modifiedEvent)
                }
            }
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
                dateString: newDateKey,
                ekEventIdentifier: oldEvent.ekEventIdentifier ?? newEvent.ekEventIdentifier,
                ekCalendarIdentifier: oldEvent.ekCalendarIdentifier ?? newEvent.ekCalendarIdentifier,
                isFromCalendar: oldEvent.isFromCalendar || newEvent.isFromCalendar
            )

            if eventsByDate[newDateKey] != nil {
                eventsByDate[newDateKey]?.append(modifiedEvent)
            } else {
                eventsByDate[newDateKey] = [modifiedEvent]
            }

            
            if modifiedEvent.isFromCalendar && calendarSyncEnabled {
                Task {
                    await syncEventToCalendar(modifiedEvent)
                }
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
        

        do {
            let syncedEvent = try await CloudSyncService.shared.saveEvent(event)
            
            await MainActor.run {
                let dateKey = event.dateString
                if let index = eventsByDate[dateKey]?.firstIndex(where: { $0.id == event.id }) {
                    eventsByDate[dateKey]?[index] = syncedEvent
                    saveEventsToLocal()
                    objectWillChange.send()
                    
                }
            }
        } catch {
            
            
        }
    }

    
    private func updateEventInCloud(_ event: DayEvent) async {
        

        do {
            let syncedEvent = try await CloudSyncService.shared.updateEvent(event)
            
            await MainActor.run {
                let dateKey = event.dateString
                if let index = eventsByDate[dateKey]?.firstIndex(where: { $0.id == event.id }) {
                    eventsByDate[dateKey]?[index] = syncedEvent
                    saveEventsToLocal()
                    objectWillChange.send()
                    
                }
            }
        } catch {
            
            
        }
    }

    
    private func deleteEventFromCloud(_ event: DayEvent) async {
        

        do {
            try await CloudSyncService.shared.deleteEvent(event)
            
        } catch {
            
            
        }
    }

    func syncWithCloud() async {
        
        

        guard cloudSyncEnabled else {
            
            return
        }

        await MainActor.run {
            isSyncing = true
            syncError = nil
        }

        

        do {
            
            let localEvents = eventsByDate.values.flatMap { $0 }
            

            
            let syncedEvents = try await CloudSyncService.shared.performFullSync(localEvents: localEvents)
            

            
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
                
            }
        }
    }

    

    
    func loadCalendarEvents() async {
        

        
        guard calendarSyncEnabled else {
            
            await MainActor.run {
                calendarEvents = []
            }
            return
        }

        
        let isAuthorized: Bool
        if #available(iOS 17.0, *) {
            isAuthorized = eventKitService.authorizationStatus == .authorized ||
                          eventKitService.authorizationStatus == EKAuthorizationStatus.fullAccess
        } else {
            isAuthorized = eventKitService.authorizationStatus == .authorized
        }

        guard isAuthorized else {
            
            await MainActor.run {
                calendarEvents = []
            }
            return
        }

        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay

        do {
            
            let ekEvents = try await eventKitService.fetchEvents(from: startOfDay, to: endOfDay)
            

            
            let convertedEvents = ekEvents.compactMap { eventKitService.convertToDayEvent($0) }

            await MainActor.run {
                self.calendarEvents = convertedEvents
                self.objectWillChange.send()
            }

            
        } catch {
            
            await MainActor.run {
                calendarEvents = []
            }
        }
    }

    
    func syncEventToCalendar(_ event: DayEvent) async {
        

        let isAuthorized: Bool
        if #available(iOS 17.0, *) {
            isAuthorized = eventKitService.authorizationStatus == .authorized ||
                          eventKitService.authorizationStatus == EKAuthorizationStatus.fullAccess
        } else {
            isAuthorized = eventKitService.authorizationStatus == .authorized
        }

        guard calendarSyncEnabled, isAuthorized,
              !eventKitService.selectedCalendars.isEmpty else {
            
            return
        }

        
        let calendarId = eventKitService.selectedCalendars.first!

        do {
            if let ekEventId = event.ekEventIdentifier {
                
                try await eventKitService.updateEvent(with: ekEventId, from: event)
                
            } else {
                
                let ekEventId = try await eventKitService.createEvent(from: event, in: calendarId)

                
                var updatedEvent = event
                updatedEvent.ekEventIdentifier = ekEventId
                updatedEvent.ekCalendarIdentifier = calendarId

                
                let dateKey = event.dateString
                if let index = eventsByDate[dateKey]?.firstIndex(where: { $0.id == event.id }) {
                    eventsByDate[dateKey]?[index] = updatedEvent
                    saveEventsToLocal()
                }

                
            }

            
            await loadCalendarEvents()
        } catch {
            
        }
    }

    
    func deleteEventFromCalendar(_ event: DayEvent) async {
        

        guard let ekEventId = event.ekEventIdentifier else {
            
            return
        }

        do {
            try await eventKitService.deleteEvent(with: ekEventId)
            

            
            await loadCalendarEvents()
        } catch {
            
        }
    }
}
