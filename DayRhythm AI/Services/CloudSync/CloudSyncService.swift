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
        
        

        let token = try await getCurrentToken()
        

        var queryParams = ""
        if let startDate = startDate, let endDate = endDate {
            queryParams = "?startDate=\(startDate)&endDate=\(endDate)"
            
        }

        guard let url = URL(string: "\(Config.backendURL)\(eventsEndpoint)\(queryParams)") else {
            
            throw CloudSyncError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            
            if let responseString = String(data: data, encoding: .utf8) {
                
            }
            throw CloudSyncError.serverError
        }

        let eventsResponse = try JSONDecoder().decode(EventsResponse.self, from: data)
        
        return eventsResponse.events.map { $0.toDayEvent() }
    }

    

    
    func saveEvent(_ event: DayEvent) async throws -> DayEvent {
        
        
        

        let token = try await getCurrentToken()
        

        guard let url = URL(string: "\(Config.backendURL)\(eventsEndpoint)") else {
            
            throw CloudSyncError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let eventData = EventData(from: event)
        request.httpBody = try JSONEncoder().encode(eventData)

        if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
            
        }

        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            
            if let responseString = String(data: data, encoding: .utf8) {
                
            }
            throw CloudSyncError.serverError
        }

        let eventResponse = try JSONDecoder().decode(EventResponse.self, from: data)
        

        
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
        
        

        guard let cloudId = event.cloudId else {
            
            
            return try await saveEvent(event)
        }

        
        

        let token = try await getCurrentToken()
        

        guard let url = URL(string: "\(Config.backendURL)\(eventsEndpoint)/\(cloudId)") else {
            
            throw CloudSyncError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let eventData = EventData(from: event)
        request.httpBody = try JSONEncoder().encode(eventData)

        if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
            
        }

        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            
            if let responseString = String(data: data, encoding: .utf8) {
                
            }
            throw CloudSyncError.serverError
        }

        let eventResponse = try JSONDecoder().decode(EventResponse.self, from: data)
        

        
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
        
        

        guard let cloudId = event.cloudId else {
            
            
            return
        }

        
        

        let token = try await getCurrentToken()
        

        guard let url = URL(string: "\(Config.backendURL)\(eventsEndpoint)/\(cloudId)") else {
            
            throw CloudSyncError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            
            if let responseString = String(data: data, encoding: .utf8) {
                
            }
            throw CloudSyncError.serverError
        }

        
    }

    
    func deleteAllEvents() async throws {
        
        

        let token = try await getCurrentToken()
        

        guard let url = URL(string: "\(Config.backendURL)\(eventsEndpoint)/all") else {
            
            throw CloudSyncError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            
            if let responseString = String(data: data, encoding: .utf8) {
                
            }
            throw CloudSyncError.serverError
        }

        
    }

    

    
    
    func batchSyncEvents(_ events: [DayEvent], clearExisting: Bool = false) async throws -> [DayEvent] {





        if clearExisting && events.isEmpty {
            print("⚠️ WARNING: batchSyncEvents called with clearExisting=true and EMPTY events array!")
            print("⚠️ This will DELETE all cloud data. If this is a first sync, fetch events first.")
        }

        let token = try await getCurrentToken()
        

        guard let url = URL(string: "\(Config.backendURL)\(batchEndpoint)") else {
            
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
            
        }

        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            
            if let responseString = String(data: data, encoding: .utf8) {
                
            }
            throw CloudSyncError.serverError
        }

        let eventsResponse = try JSONDecoder().decode(EventsResponse.self, from: data)
        

        return eventsResponse.events.map { cloudEvent in
            let dayEvent = cloudEvent.toDayEvent()
            
            return dayEvent
        }
    }

    

    
    
    func performFullSync(localEvents: [DayEvent]) async throws -> [DayEvent] {
        
        

        
        let cloudEvents = try await fetchEvents()
        

        
        let resolvedEvents = storageManager.resolveConflicts(
            localEvents: localEvents,
            cloudEvents: cloudEvents
        )
        

        
        let eventsToUpload = resolvedEvents.filter { $0.syncStatus == .pending || $0.cloudId == nil }
        

        
        var syncedEvents: [DayEvent] = []
        for event in eventsToUpload {
            do {
                
                let syncedEvent = try await (event.cloudId != nil ? updateEvent(event) : saveEvent(event))
                syncedEvents.append(syncedEvent)
            } catch {
                
                syncedEvents.append(event)  
            }
        }

        
        let alreadySynced = resolvedEvents.filter { $0.syncStatus == .synced && $0.cloudId != nil }
        let allEvents = syncedEvents + alreadySynced

        
        
        

        
        storageManager.saveEventsLocally(allEvents)
        storageManager.lastSyncDate = Date()

        
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