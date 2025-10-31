//
//  BackendModels.swift
//  DayRhythm AI
//
//  Created by Claude on 31/10/25.
//

import Foundation

struct ConversationMessage: Codable, Identifiable {
    let id: UUID
    let role: String  
    let content: String
    let timestamp: Date

    init(id: UUID = UUID(), role: String, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }

    
    func toAPIFormat() -> [String: String] {
        return ["role": role, "content": content]
    }
}

struct ParseScheduleResponse: Codable {
    let success: Bool
    let data: ParseScheduleData
}

struct ParseScheduleData: Codable {
    let events: [BackendParsedTask]
}

struct BackendParsedTask: Codable {
    let title: String
    let description: String
    let startTime: Double
    let endTime: Double
    let date: String
    let emoji: String
    let colorHex: String
}



struct DayInsightsResponse: Codable {
    let success: Bool
    let data: DayInsightsData
}

struct DayInsightsData: Codable {
    let insights: [String]
    let visualInsights: VisualInsights?
}

// MARK: - Visual Insights Models

struct VisualInsights: Codable {
    let energyHeatmap: [EnergyHeatmapItem]
    let focusBlocks: [FocusBlock]
    let workLifeBalance: WorkLifeBalance
}

struct EnergyHeatmapItem: Codable, Identifiable {
    var id: String { title }
    let title: String
    let startTime: Double
    let endTime: Double
    let optimalEnergy: String
    let actualTaskType: String
    let alignment: String
    let category: String
}

struct FocusBlock: Codable, Identifiable {
    var id: String { title }
    let title: String
    let startTime: Double
    let duration: Double
    let quality: String
    let hasBreakAfter: Bool
    let category: String
}

struct WorkLifeBalance: Codable {
    let work: Double
    let personal: Double
    let health: Double
    let other: Double
    let workPercentage: Int
    let personalPercentage: Int
    let healthPercentage: Int
    let otherPercentage: Int
    let balanceScore: Int
}



struct TaskInsightResponse: Codable {
    let success: Bool
    let data: TaskInsightData
}

struct TaskInsightData: Codable {
    let insight: String
}



struct AnalyticsResponse: Codable {
    let success: Bool
    let data: AnalyticsData
}

struct AnalyticsData: Codable {
    let summary: String
    let totalEvents: Int
    let totalHours: Double
    let averageEventsPerDay: Double
    let dateRange: DateRange
}

struct DateRange: Codable {
    let startDate: String
    let endDate: String
}



struct BackendErrorResponse: Codable {
    let success: Bool
    let error: String
}
