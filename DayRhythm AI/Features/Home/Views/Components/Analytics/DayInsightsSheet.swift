//
//  DayInsightsSheet.swift
//  DayRhythm AI
//
//  Created by kartikay on 25/10/25.
//

import SwiftUI

struct DayInsightsSheet: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var insights: [String] = []
    @State private var isLoadingInsights = false
    @State private var pieChartData: [PieChartView.ChartData] = []
    @State private var timelineData: [TimelineBarChart.HourData] = []
    @State private var showLoginSheet = false
    @State private var showSignupSheet = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Day Insights")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)

                            Text(formattedDate)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.6))
                        }

                        Spacer()

                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    
                    CircularDayDial(
                        events: homeViewModel.events,
                        selectedDate: homeViewModel.selectedDate
                    )
                    .frame(height: 200)
                    .scaleEffect(0.6)
                    .padding(.vertical, -40) 

                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Time Distribution")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                
                                VStack(spacing: 12) {
                                    PieChartView(data: pieChartData)

                                    PieChartLegend(data: pieChartData)
                                        .frame(width: 200)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.05))
                                )

                                
                                TimelineBarChart(hourlyData: timelineData)
                                    .frame(width: 280)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white.opacity(0.05))
                                    )

                                
                                StatsCard(events: homeViewModel.events)
                                    .frame(width: 200)
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("AI Insights")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)

                            Spacer()

                            if isLoadingInsights {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.8)
                            } else {
                                Button(action: generateInsights) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 14))
                                        .foregroundColor(.black)
                                        .padding(6)
                                        .background(
                                            Circle()
                                                .fill(Color.white)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        if insights.isEmpty && !isLoadingInsights {
                            Button(action: {
                                if appState.isAuthenticated {
                                    generateInsights()
                                } else {
                                    showLoginSheet = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: appState.isAuthenticated ? "sparkles" : "lock.fill")
                                    Text(appState.isAuthenticated ? "Generate AI Insights" : "Sign in to Generate Insights")
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                )
                            }
                            .padding(.horizontal, 20)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(Array(insights.enumerated()), id: \.offset) { index, insight in
                                    InsightCard(
                                        icon: insightIcon(for: index),
                                        text: insight,
                                        color: insightColor(for: index)
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    Spacer(minLength: 20)
                }
            }
        }
        .onAppear {
            calculateChartData()
        }
        .sheet(isPresented: $showLoginSheet) {
            DarkLoginSheet()
        }
        .sheet(isPresented: $showSignupSheet) {
            DarkSignupSheet()
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: homeViewModel.selectedDate)
    }

    private func calculateChartData() {
        
        var categoryTimes: [String: (Double, Color, String)] = [:]

        for event in homeViewModel.events {
            let key = event.category
            if let existing = categoryTimes[key] {
                categoryTimes[key] = (existing.0 + event.duration, event.color, event.emoji)
            } else {
                categoryTimes[key] = (event.duration, event.color, event.emoji)
            }
        }

        
        pieChartData = categoryTimes.map { category, data in
            PieChartView.ChartData(
                category: category,
                value: data.0,
                color: data.1,
                emoji: data.2
            )
        }.sorted { $0.value > $1.value }

        
        var hourlyIntensity: [Int: (Double, Color, String)] = [:]

        for event in homeViewModel.events {
            let startHour = Int(event.startHour)
            let endHour = Int(ceil(event.startHour + event.duration))

            for hour in startHour..<endHour {
                if hour < 24 {
                    hourlyIntensity[hour] = (1.0, event.color, event.title)
                }
            }
        }

        timelineData = hourlyIntensity.map { hour, data in
            TimelineBarChart.HourData(
                hour: hour,
                intensity: data.0,
                color: data.1,
                taskName: data.2
            )
        }
    }

    private func generateInsights() {
        isLoadingInsights = true

        Task {
            do {
                
                let generatedInsights = try await BackendService.shared.getDayInsights(
                    date: homeViewModel.selectedDate
                )

                await MainActor.run {
                    insights = generatedInsights
                    isLoadingInsights = false
                }
                print("✅ Received \(generatedInsights.count) insights from backend")
            } catch let error as BackendError {
                await MainActor.run {
                    isLoadingInsights = false
                    print("❌ Backend error: \(error.localizedDescription)")

                    
                    Task {
                        let fallbackInsights = await GroqService.shared.generateDayInsights(
                            events: homeViewModel.events,
                            date: homeViewModel.selectedDate
                        )
                        await MainActor.run {
                            insights = fallbackInsights
                        }
                        print("⚠️ Used fallback Groq service")
                    }
                }
            } catch {
                await MainActor.run {
                    isLoadingInsights = false
                    print("❌ Unexpected error: \(error)")

                    
                    Task {
                        let fallbackInsights = await GroqService.shared.generateDayInsights(
                            events: homeViewModel.events,
                            date: homeViewModel.selectedDate
                        )
                        await MainActor.run {
                            insights = fallbackInsights
                        }
                    }
                }
            }
        }
    }

    private func insightIcon(for index: Int) -> String {
        let icons = ["chart.line.uptrend.xyaxis", "clock", "lightbulb", "chart.pie", "bolt"]
        return icons[index % icons.count]
    }

    private func insightColor(for index: Int) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink]
        return colors[index % colors.count]
    }
}

struct StatsCard: View {
    let events: [DayEvent]

    var totalHours: Double {
        events.reduce(0) { $0 + $1.duration }
    }

    var freeHours: Double {
        max(0, 24 - totalHours)
    }

    var productivityScore: Int {
        let score = min(100, Int((totalHours / 12) * 100))
        return max(0, score)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Stats")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))

            VStack(spacing: 12) {
                StatRow(label: "Tasks", value: "\(events.count)", icon: "checkmark.circle")
                StatRow(label: "Scheduled", value: String(format: "%.1fh", totalHours), icon: "clock")
                StatRow(label: "Free Time", value: String(format: "%.1fh", freeHours), icon: "sparkles")

                
                VStack(spacing: 4) {
                    HStack {
                        Text("Productivity")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.white.opacity(0.6))

                        Spacer()

                        Text("\(productivityScore)%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))

                            RoundedRectangle(cornerRadius: 4)
                                .fill(LinearGradient(
                                    colors: [.green, .yellow, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(width: geometry.size.width * (Double(productivityScore) / 100))
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 20)

            Text(label)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.6))

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

struct InsightCard: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(color.opacity(0.2))
                )

            Text(text)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(3)

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

#Preview {
    DayInsightsSheet(homeViewModel: HomeViewModel())
}