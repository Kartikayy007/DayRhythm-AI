//
//  CloudSyncService.swift
//  DayRhythm AI
//
//  Created by Kartikay on 01/11/25.
//

import Foundation
import SwiftUI
import Supabase


class CloudSyncService {
    static let shared = CloudSyncService()

    private let backendService = BackendService.shared
    private let storageManager = StorageManager.shared

    
    
    private let eventsEndpoint = "/events"
    private let batchEndpoint = "/events/batch"

    private init() {}

    
    private func getCurrentToken() async throws -> String {
        let supabase = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseAnonKey
        )

        guard let session = supabase.auth.currentSession else {
            throw CloudSyncError.notAuthenticated
        }

        return session.accessToken
    }

    

    
    func fetchEvents(startDate: String? = nil, endDate: String? = nil) async throws -> [DayEvent] {
        print("🔵 [CLOUD SYNC] fetchEvents() called")
        print("🔵 [CLOUD SYNC] URL: \(Config.backendURL)\(eventsEndpoint)")

        let token = try await getCurrentToken()
        print("🔵 [CLOUD SYNC] Token obtained: \(token.prefix(20))...")

        var queryParams = ""
        if let startDate = startDate, let endDate = endDate {
            queryParams = "?startDate=\(startDate)&endDate=\(endDate)"
            print("🔵 [CLOUD SYNC] Date filter: \(startDate) to \(endDate)")
        }

        guard let url = URL(string: "\(Config.backendURL)\(eventsEndpoint)\(queryParams)") else {
            print("❌ [CLOUD SYNC] Invalid URL")
            throw CloudSyncError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print("🔵 [CLOUD SYNC] Sending GET request to: \(url)")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("❌ [CLOUD SYNC] GET /api/events failed with status: \(statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ [CLOUD SYNC] Response: \(responseString)")
            }
            throw CloudSyncError.serverError
        }

        let eventsResponse = try JSONDecoder().decode(EventsResponse.self, from: data)
        print("✅ [CLOUD SYNC] Successfully fetched \(eventsResponse.events.count) events")
        return eventsResponse.events.map { $0.toDayEvent() }
    }

    

    
    func saveEvent(_ event: DayEvent) async throws -> DayEvent {
        print("🟢 [CLOUD SYNC] saveEvent() called")
        print("🟢 [CLOUD SYNC] Event: \(event.title) at \(event.startHour)-\(event.endHour)")
        print("🟢 [CLOUD SYNC] URL: \(Config.backendURL)\(eventsEndpoint)")

        let token = try await getCurrentToken()
        print("🟢 [CLOUD SYNC] Token obtained: \(token.prefix(20))...")

        guard let url = URL(string: "\(Config.backendURL)\(eventsEndpoint)") else {
            print("❌ [CLOUD SYNC] Invalid URL")
            throw CloudSyncError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let eventData = EventData(from: event)
        request.httpBody = try JSONEncoder().encode(eventData)

        if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
            print("🟢 [CLOUD SYNC] Request body: \(bodyString)")
        }

        print("🟢 [CLOUD SYNC] Sending POST request to: \(url)")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("❌ [CLOUD SYNC] POST /api/events failed with status: \(statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ [CLOUD SYNC] Response: \(responseString)")
            }
            throw CloudSyncError.serverError
        }

        let eventResponse = try JSONDecoder().decode(EventResponse.self, from: data)
        print("✅ [CLOUD SYNC] Successfully saved event, cloudId: \(eventResponse.event.id)")

        
        let updatedEvent = DayEvent(
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
            cloudId: eventResponse.event.id,
            syncStatus: .synced,
            lastModified: event.lastModified,
            dateString: event.dateString
        )
        return updatedEvent
    }

    

    
    func updateEvent(_ event: DayEvent) async throws -> DayEvent {
        print("🟡 [CLOUD SYNC] updateEvent() called")
        print("🟡 [CLOUD SYNC] Event: \(event.title)")

        guard let cloudId = event.cloudId else {
            
            print("⚠️ [CLOUD SYNC] No cloudId, calling saveEvent instead")
            return try await saveEvent(event)
        }

        print("🟡 [CLOUD SYNC] CloudId: \(cloudId)")
        print("🟡 [CLOUD SYNC] URL: \(Config.backendURL)\(eventsEndpoint)/\(cloudId)")

        let token = try await getCurrentToken()
        print("🟡 [CLOUD SYNC] Token obtained: \(token.prefix(20))...")

        guard let url = URL(string: "\(Config.backendURL)\(eventsEndpoint)/\(cloudId)") else {
            print("❌ [CLOUD SYNC] Invalid URL")
            throw CloudSyncError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let eventData = EventData(from: event)
        request.httpBody = try JSONEncoder().encode(eventData)

        if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
            print("🟡 [CLOUD SYNC] Request body: \(bodyString)")
        }

        print("🟡 [CLOUD SYNC] Sending PUT request to: \(url)")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("❌ [CLOUD SYNC] PUT /api/events/:id failed with status: \(statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ [CLOUD SYNC] Response: \(responseString)")
            }
            throw CloudSyncError.serverError
        }

        let eventResponse = try JSONDecoder().decode(EventResponse.self, from: data)
        print("✅ [CLOUD SYNC] Successfully updated event, cloudId: \(eventResponse.event.id)")

        
        let updatedEvent = DayEvent(
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
            cloudId: eventResponse.event.id,
            syncStatus: .synced,
            lastModified: event.lastModified,
            dateString: event.dateString
        )
        return updatedEvent
    }

    

    
    func deleteEvent(_ event: DayEvent) async throws {
        print("🔴 [CLOUD SYNC] deleteEvent() called")
        print("🔴 [CLOUD SYNC] Event: \(event.title)")

        guard let cloudId = event.cloudId else {
            
            print("⚠️ [CLOUD SYNC] No cloudId, skipping cloud delete")
            return
        }

        print("🔴 [CLOUD SYNC] CloudId: \(cloudId)")
        print("🔴 [CLOUD SYNC] URL: \(Config.backendURL)\(eventsEndpoint)/\(cloudId)")

        let token = try await getCurrentToken()
        print("🔴 [CLOUD SYNC] Token obtained: \(token.prefix(20))...")

        guard let url = URL(string: "\(Config.backendURL)\(eventsEndpoint)/\(cloudId)") else {
            print("❌ [CLOUD SYNC] Invalid URL")
            throw CloudSyncError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        print("🔴 [CLOUD SYNC] Sending DELETE request to: \(url)")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("❌ [CLOUD SYNC] DELETE /api/events/:id failed with status: \(statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ [CLOUD SYNC] Response: \(responseString)")
            }
            throw CloudSyncError.serverError
        }

        print("✅ [CLOUD SYNC] Successfully deleted event from cloud")
    }

    
    func deleteAllEvents() async throws {
        print("🔴🔴 [CLOUD SYNC] deleteAllEvents() called")
        print("🔴🔴 [CLOUD SYNC] URL: \(Config.backendURL)\(eventsEndpoint)/all")

        let token = try await getCurrentToken()
        print("🔴🔴 [CLOUD SYNC] Token obtained: \(token.prefix(20))...")

        guard let url = URL(string: "\(Config.backendURL)\(eventsEndpoint)/all") else {
            print("❌ [CLOUD SYNC] Invalid URL")
            throw CloudSyncError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        print("🔴🔴 [CLOUD SYNC] Sending DELETE request to: \(url)")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("❌ [CLOUD SYNC] DELETE /api/events/all failed with status: \(statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ [CLOUD SYNC] Response: \(responseString)")
            }
            throw CloudSyncError.serverError
        }

        print("✅ [CLOUD SYNC] Successfully deleted all events from cloud")
    }

    

    
    
    func batchSyncEvents(_ events: [DayEvent], clearExisting: Bool = false) async throws -> [DayEvent] {
        print("🟣 [CLOUD SYNC] batchSyncEvents() called")
        print("🟣 [CLOUD SYNC] Events count: \(events.count)")
        print("🟣 [CLOUD SYNC] Clear existing: \(clearExisting)")
        print("🟣 [CLOUD SYNC] URL: \(Config.backendURL)\(batchEndpoint)")

        let token = try await getCurrentToken()
        print("🟣 [CLOUD SYNC] Token obtained: \(token.prefix(20))...")

        guard let url = URL(string: "\(Config.backendURL)\(batchEndpoint)") else {
            print("❌ [CLOUD SYNC] Invalid URL")
            throw CloudSyncError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let batchData = BatchEventData(
            events: events.map { EventData(from: $0) },
            clearExisting: clearExisting
        )
        request.httpBody = try JSONEncoder().encode(batchData)

        if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
            print("🟣 [CLOUD SYNC] Request body preview: \(bodyString.prefix(200))...")
        }

        print("🟣 [CLOUD SYNC] Sending POST request to: \(url)")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("❌ [CLOUD SYNC] POST /api/events/batch failed with status: \(statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ [CLOUD SYNC] Response: \(responseString)")
            }
            throw CloudSyncError.serverError
        }

        let eventsResponse = try JSONDecoder().decode(EventsResponse.self, from: data)
        print("✅ [CLOUD SYNC] Successfully batch synced \(eventsResponse.events.count) events")

        return eventsResponse.events.map { cloudEvent in
            let dayEvent = cloudEvent.toDayEvent()
            
            return dayEvent
        }
    }

    

    
    
    func performFullSync(localEvents: [DayEvent]) async throws -> [DayEvent] {
        print("⚡️ [CLOUD SYNC] performFullSync() called")
        print("⚡️ [CLOUD SYNC] Local events count: \(localEvents.count)")

        
        let cloudEvents = try await fetchEvents()
        print("⚡️ [CLOUD SYNC] Cloud events count: \(cloudEvents.count)")

        
        let resolvedEvents = storageManager.resolveConflicts(
            localEvents: localEvents,
            cloudEvents: cloudEvents
        )
        print("⚡️ [CLOUD SYNC] Resolved events count: \(resolvedEvents.count)")

        
        let eventsToUpload = resolvedEvents.filter { $0.syncStatus == .pending || $0.cloudId == nil }
        print("⚡️ [CLOUD SYNC] Events to upload: \(eventsToUpload.count)")

        
        var syncedEvents: [DayEvent] = []
        for event in eventsToUpload {
            do {
                print("⚡️ [CLOUD SYNC] Uploading event: \(event.title)")
                let syncedEvent = try await (event.cloudId != nil ? updateEvent(event) : saveEvent(event))
                syncedEvents.append(syncedEvent)
            } catch {
                print("❌ [CLOUD SYNC] Failed to sync event \(event.id): \(error)")
                syncedEvents.append(event)  
            }
        }

        
        let alreadySynced = resolvedEvents.filter { $0.syncStatus == .synced && $0.cloudId != nil }
        let allEvents = syncedEvents + alreadySynced

        print("⚡️ [CLOUD SYNC] Total synced events: \(syncedEvents.count)")
        print("⚡️ [CLOUD SYNC] Already synced events: \(alreadySynced.count)")
        print("⚡️ [CLOUD SYNC] All events: \(allEvents.count)")

        
        storageManager.saveEventsLocally(allEvents)
        storageManager.lastSyncDate = Date()

        print("✅ [CLOUD SYNC] performFullSync completed successfully")
        return allEvents
    }
}



enum CloudSyncError: LocalizedError {
    case notAuthenticated
    case invalidURL
    case serverError
    case encodingError
    case decodingError

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User is not authenticated. Please log in."
        case .invalidURL:
            return "Invalid server URL."
        case .serverError:
            return "Server error. Please try again later."
        case .encodingError:
            return "Failed to encode data."
        case .decodingError:
            return "Failed to decode server response."
        }
    }
}




struct EventData: Codable {
    let title: String
    let description: String
    let startTime: Double
    let endTime: Double
    let date: String
    let emoji: String
    let colorHex: String
    let category: String
    let participants: [String]
    let isCompleted: Bool
    let notificationSettings: NotificationSettings
    let localId: String 

    init(from event: DayEvent) {
        self.title = event.title
        self.description = event.description
        self.startTime = event.startHour
        self.endTime = event.endHour
        self.date = event.dateString
        self.emoji = event.emoji
        self.colorHex = event.color.toHex()
        self.category = event.category
        self.participants = event.participants
        self.isCompleted = event.isCompleted
        self.notificationSettings = event.notificationSettings
        self.localId = event.id.uuidString 
    }
}


struct BatchEventData: Codable {
    let events: [EventData]
    let clearExisting: Bool
}


struct CloudEvent: Codable {
    let id: String
    let userId: String
    let title: String
    let description: String?
    let startTime: Double
    let endTime: Double
    let date: String
    let emoji: String?
    let colorHex: String?
    let category: String?
    let participants: [String]?
    let isCompleted: Bool?
    let notificationSettings: NotificationSettings?
    let localId: String? 
    let createdAt: String
    let updatedAt: String

    func toDayEvent() -> DayEvent {
        
        let eventId: UUID
        if let localId = localId, let uuid = UUID(uuidString: localId) {
            
            eventId = uuid
        } else {
            
            
            let data = id.data(using: .utf8) ?? Data()
            let hash = data.reduce(0) { $0 &+ Int($1) }
            eventId = UUID(uuid: (UInt8(hash & 0xFF), UInt8((hash >> 8) & 0xFF),
                                  UInt8((hash >> 16) & 0xFF), UInt8((hash >> 24) & 0xFF),
                                  UInt8((hash >> 32) & 0xFF), UInt8((hash >> 40) & 0xFF),
                                  UInt8((hash >> 48) & 0xFF), UInt8((hash >> 56) & 0xFF),
                                  UInt8(0x40), UInt8(0x80), 
                                  UInt8.random(in: 0...255), UInt8.random(in: 0...255),
                                  UInt8.random(in: 0...255), UInt8.random(in: 0...255),
                                  UInt8.random(in: 0...255), UInt8.random(in: 0...255)))
        }

        return DayEvent(
            id: eventId,
            title: title,
            startHour: startTime,
            endHour: endTime,
            color: Color(hex: colorHex ?? "#FF6B35") ?? .orange,
            category: category ?? "",
            emoji: emoji ?? "📅",
            description: description ?? "",
            participants: participants ?? [],
            isCompleted: isCompleted ?? false,
            notificationSettings: notificationSettings ?? .disabled,
            cloudId: id,
            syncStatus: .synced,
            lastModified: ISO8601DateFormatter().date(from: updatedAt),
            dateString: date
        )
    }
}


struct EventResponse: Codable {
    let success: Bool
    let event: CloudEvent
}

struct EventsResponse: Codable {
    let success: Bool
    let events: [CloudEvent]
    let count: Int
}