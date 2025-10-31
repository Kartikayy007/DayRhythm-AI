//
//  BackendService.swift
//  DayRhythm AI
//
//  Created by Claude on 31/10/25.
//

import Foundation
import Supabase

enum BackendError: LocalizedError {
    case networkError
    case unauthorized
    case invalidResponse
    case serverError(String)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network error. Please check your connection."
        case .unauthorized:
            return "Please sign in to use AI features."
        case .invalidResponse:
            return "Invalid response from server."
        case .serverError(let message):
            return message
        case .decodingError:
            return "Failed to process server response."
        }
    }
}

class BackendService {
    static let shared = BackendService()

    private let baseURL = Config.backendURL
    private let authService = AuthenticationService.shared

    private init() {}

    
    func parseSchedule(prompt: String) async throws -> [BackendParsedTask] {
        let endpoint = "\(baseURL)/api/ai/parse-schedule"

        let body: [String: Any] = ["prompt": prompt]

        let response: ParseScheduleResponse = try await makeAuthenticatedRequest(
            endpoint: endpoint,
            method: "POST",
            body: body
        )

        return response.data.events
    }

    

    
    
    
    func getDayInsights(date: Date) async throws -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        let endpoint = "\(baseURL)/api/ai/insights"
        let body: [String: Any] = ["date": dateString]

        let response: DayInsightsResponse = try await makeAuthenticatedRequest(
            endpoint: endpoint,
            method: "POST",
            body: body
        )

        return response.data.insights
    }

    func getTaskInsight(task: DayEvent) async throws -> String {
        let endpoint = "\(baseURL)/api/ai/task-insight"
        let body: [String: Any] = [
            "title": task.title,
            "description": task.description,
            "startTime": task.startHour,
            "endTime": task.endHour,
            "category": task.category
        ]

        let response: TaskInsightResponse = try await makeAuthenticatedRequest(
            endpoint: endpoint,
            method: "POST",
            body: body
        )

        return response.data.insight
    }

    func getAnalytics(startDate: Date, endDate: Date) async throws -> AnalyticsData {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let endpoint = "\(baseURL)/api/ai/analytics"
        let body: [String: Any] = [
            "startDate": dateFormatter.string(from: startDate),
            "endDate": dateFormatter.string(from: endDate)
        ]

        let response: AnalyticsResponse = try await makeAuthenticatedRequest(
            endpoint: endpoint,
            method: "POST",
            body: body
        )

        return response.data
    }
    
    private func makeAuthenticatedRequest<T: Decodable>(
        endpoint: String,
        method: String,
        body: [String: Any]? = nil
    ) async throws -> T {
        let supabase = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseAnonKey
        )

        guard let session = supabase.auth.currentSession else {
            throw BackendError.unauthorized
        }

        let token = session.accessToken

        guard let url = URL(string: endpoint) else {
            throw BackendError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw BackendError.invalidResponse
            }

            
            switch httpResponse.statusCode {
            case 200...299:
                
                let decoder = JSONDecoder()
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    print("Decoding error: \(error)")
                    print("Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    throw BackendError.decodingError
                }

            case 401:
                
                throw BackendError.unauthorized

            case 400...499:
                
                if let errorResponse = try? JSONDecoder().decode(BackendErrorResponse.self, from: data) {
                    throw BackendError.serverError(errorResponse.error)
                } else {
                    throw BackendError.serverError("Request failed with status \(httpResponse.statusCode)")
                }

            case 500...599:
                
                if let errorResponse = try? JSONDecoder().decode(BackendErrorResponse.self, from: data) {
                    throw BackendError.serverError(errorResponse.error)
                } else {
                    throw BackendError.serverError("Server error occurred")
                }

            default:
                throw BackendError.invalidResponse
            }

        } catch let error as BackendError {
            throw error
        } catch {
            print("Network error: \(error)")
            throw BackendError.networkError
        }
    }
}
