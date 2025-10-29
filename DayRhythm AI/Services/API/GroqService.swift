//
//  GroqService.swift
//  DayRhythm AI
//
//  Created by kartikay on 25/10/25.
//

import Foundation
import SwiftUI

struct ParsedTask: Codable {
    let title: String
    let description: String
    let startTime: Double
    let endTime: Double
    let date: String 
    let emoji: String
    let colorHex: String
}

class GroqService {
    static let shared = GroqService()

    private let apiKey = Config.groqAPIKey
    private let baseURL = "https://api.groq.com/openai/v1/chat/completions"

    func parseTaskFromDescription(_ description: String) async -> [ParsedTask] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDate = dateFormatter.string(from: Date())

        let systemPrompt = """
        You are a task parsing Assistant. Your ONLY job is to return valid JSON, nothing else.
        Today's date is: \(todayDate)

        If the user describes MULTIPLE tasks, return a JSON ARRAY. If ONE task, return a single object.

        Return ONLY ONE of these formats:
        Single task: {"title":"Meeting","description":"Team meeting","startTime":15.0,"endTime":16.0,"date":"2025-10-25","emoji":"📅","colorHex":"#FFD78F"}

        Multiple tasks: [{"title":"Meeting","description":"Team meeting","startTime":15.0,"endTime":16.0,"date":"2025-10-25","emoji":"📅","colorHex":"#FFD78F"},{"title":"Code","description":"Coding session","startTime":9.0,"endTime":11.0,"date":"2025-10-26","emoji":"💻","colorHex":"#6495ED"}]

        RULES:
        - ALWAYS return ONLY valid JSON. No text before or after.
        - startTime & endTime: 24-hour format (0-24). Examples:
          * "3pm" or "3 in afternoon" → startTime: 15.0
          * "9am" or "9 in morning" → startTime: 9.0
          * "7 evening" → startTime: 19.0
          * Just "3" for business tasks → assume PM → 15.0
          * Just "8" for breakfast → assume AM → 8.0
        - date: yyyy-MM-dd format. Calculate from today (\(todayDate)):
          * "today" → \(todayDate)
          * "tomorrow" → add 1 day
          * "day after tomorrow" → add 2 days
        - If no time specified: startTime: 9.0, endTime: 10.0 (default 1 hour at 9 AM)
        - If no date specified: use today's date (\(todayDate))
        - emoji: choose relevant emoji
        - colorHex: choose appropriate 6-digit hex color
        """

        let userMessage = "Parse all tasks from: \(description)"

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "model": "llama-3.3-70b-versatile",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userMessage]
            ],
            "temperature": 0.7,
            "max_tokens": 500
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                return []
            }

            if httpResponse.statusCode != 200 {
                let errorBody = String(data: data, encoding: .utf8) ?? "No error details"
                print("API Error - Status: \(httpResponse.statusCode), Body: \(errorBody)")
                return []
            }

            let decodedResponse = try JSONDecoder().decode(GroqResponse.self, from: data)

            guard let content = decodedResponse.choices.first?.message.content else {
                print("No content in response")
                return []
            }

            print("API Response content: \(content)")

            
            if let jsonData = content.data(using: .utf8) {
                do {
                    
                    let parsedTasks = try JSONDecoder().decode([ParsedTask].self, from: jsonData)
                    print("Parsed array with \(parsedTasks.count) tasks")
                    return parsedTasks
                } catch {
                    
                    do {
                        let parsedTask = try JSONDecoder().decode(ParsedTask.self, from: jsonData)
                        print("Parsed single task")
                        return [parsedTask]  
                    } catch {
                        print("JSON Decoding Error (both array and single): \(error)")
                        print("Attempted to parse: \(content)")
                        return []
                    }
                }
            }

            return []
        } catch {
            print("Network Error: \(error)")
            return []
        }
    }

    func generateDayInsights(events: [DayEvent], date: Date) async -> [String] {
        
        let totalTasks = events.count
        let totalHours = events.reduce(0) { $0 + $1.duration }
        let freeHours = max(0, 24 - totalHours)

        
        var categoryBreakdown: [String: Double] = [:]
        for event in events {
            categoryBreakdown[event.category, default: 0] += event.duration
        }

        
        let longestTask = events.max(by: { $0.duration < $1.duration })

        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        let dateString = dateFormatter.string(from: date)

        let systemPrompt = """
        You are a productivity insights Assistant. Analyze the user's daily schedule and provide helpful insights.

        Return ONLY a JSON array of 5 insightful strings. Each insight should be:
        - Concise (under 100 characters)
        - Specific and actionable
        - Positive and encouraging
        - Data-driven based on the schedule

        Example format:
        ["Your morning is optimized for deep work with 3 continuous hours", "42% free time allows for spontaneous activities", "Consider a 15-min break after your longest task"]
        """

        let userMessage = """
        Analyze this schedule for \(dateString):
        - Total tasks: \(totalTasks)
        - Scheduled hours: \(String(format: "%.1f", totalHours))
        - Free time: \(String(format: "%.1f", freeHours)) hours
        - Categories: \(categoryBreakdown.map { "\($0.key): \(String(format: "%.1f", $0.value))h" }.joined(separator: ", "))
        - Longest task: \(longestTask?.title ?? "None") (\(String(format: "%.1f", longestTask?.duration ?? 0))h)

        Provide 5 insights about productivity, balance, and optimization.
        """

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "model": "llama-3.3-70b-versatile",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userMessage]
            ],
            "temperature": 0.7,
            "max_tokens": 300
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return generateFallbackInsights(events: events, totalHours: totalHours, freeHours: freeHours)
            }

            let decodedResponse = try JSONDecoder().decode(GroqResponse.self, from: data)

            guard let content = decodedResponse.choices.first?.message.content,
                  let jsonData = content.data(using: .utf8),
                  let insights = try? JSONDecoder().decode([String].self, from: jsonData) else {
                return generateFallbackInsights(events: events, totalHours: totalHours, freeHours: freeHours)
            }

            return insights
        } catch {
            print("Error generating insights: \(error)")
            return generateFallbackInsights(events: events, totalHours: totalHours, freeHours: freeHours)
        }
    }

    func generateTaskInsight(for task: DayEvent) async -> String {
        let systemPrompt = """
        You are a productivity insights assistant. Analyze a single task and provide a personalized 2-3 sentence insight.

        Focus on:
        - Optimal timing and energy levels for this type of task
        - Productivity tips specific to this activity
        - Time management suggestions based on duration
        - Contextual advice that feels personal and actionable

        Return ONLY plain text (no JSON, no quotes). Be conversational and encouraging.
        """

        let userMessage = """
        Analyze this task:
        - Title: \(task.title)
        - Duration: \(task.durationString)
        - Time: \(task.timeString)
        - Category: \(task.category)
        - Description: \(task.description)

        Provide a brief, personalized insight (2-3 sentences) about how to approach this task effectively.
        """

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "model": "llama-3.3-70b-versatile",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userMessage]
            ],
            "temperature": 0.8,
            "max_tokens": 150
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return generateFallbackTaskInsight(for: task)
            }

            let decodedResponse = try JSONDecoder().decode(GroqResponse.self, from: data)

            guard let content = decodedResponse.choices.first?.message.content else {
                return generateFallbackTaskInsight(for: task)
            }

            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("Error generating task insight: \(error)")
            return generateFallbackTaskInsight(for: task)
        }
    }

    private func generateFallbackTaskInsight(for task: DayEvent) -> String {
        let hour = Int(task.startHour)
        let duration = task.duration

        if hour < 10 {
            return "Morning tasks like this benefit from fresh mental energy. \(task.durationString) is a solid duration - consider tackling the hardest parts first while your focus is strongest."
        } else if hour < 14 {
            return "Mid-day scheduling gives you momentum from earlier wins. For \(task.durationString), break it into focused 25-minute chunks with short breaks between to maintain peak performance."
        } else if hour < 18 {
            return "Afternoon tasks work well when you match them to your energy. Since this runs \(task.durationString), consider pairing it with a quick energizing break or snack to stay sharp throughout."
        } else {
            return "Evening tasks can be highly productive with the right approach. For \(task.durationString), minimize distractions and create a comfortable environment to help you stay engaged."
        }
    }

    private func generateFallbackInsights(events: [DayEvent], totalHours: Double, freeHours: Double) -> [String] {
        var insights: [String] = []

        
        if totalHours > 0 {
            insights.append("You have \(String(format: "%.1f", totalHours)) hours scheduled across \(events.count) tasks")
        }

        if freeHours > 8 {
            insights.append("\(Int((freeHours / 24) * 100))% of your day is free - perfect for flexibility")
        } else if freeHours < 4 {
            insights.append("Your schedule is quite packed - remember to take breaks")
        }

        
        let morningTasks = events.filter { $0.startHour >= 6 && $0.startHour < 12 }
        if morningTasks.count > 2 {
            insights.append("Your morning is productive with \(morningTasks.count) tasks scheduled")
        }

        
        let workTasks = events.filter { $0.category.lowercased().contains("work") }
        if workTasks.count > 0 {
            let workHours = workTasks.reduce(0) { $0 + $1.duration }
            let workPercent = Int((workHours / totalHours) * 100)
            insights.append("Work comprises \(workPercent)% of your scheduled time")
        }

        
        if let longest = events.max(by: { $0.duration < $1.duration }) {
            insights.append("'\(longest.title)' is your longest task at \(String(format: "%.1f", longest.duration)) hours")
        }

        return Array(insights.prefix(5))
    }
}



struct GroqResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message

        struct Message: Codable {
            let content: String
        }
    }
}
