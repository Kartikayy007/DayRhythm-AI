//
//  TaskVisualInsight.swift
//  DayRhythm AI
//
//  Created by Claude on 31/10/25.
//

import SwiftUI

struct TaskVisualInsight: View {
    let task: DayEvent
    let allEvents: [DayEvent]

    var energyAlignment: (score: Int, label: String, color: Color) {
        let hour = Int(task.startHour)
        let category = task.category.lowercased()

        // Check if task type matches optimal time
        let isDeepWork = category.contains("work") || category.contains("coding") || category.contains("focus")
        let isMeeting = category.contains("meeting") || category.contains("call")
        let isCreative = category.contains("design") || category.contains("creative")

        if hour >= 9 && hour < 12 {
            // Peak morning hours - best for deep work
            if isDeepWork {
                return (95, "Optimal Timing", .green)
            } else if isMeeting {
                return (60, "Consider Earlier", .yellow)
            } else {
                return (75, "Good Timing", .blue)
            }
        } else if hour >= 14 && hour < 16 {
            // Post-lunch dip - worst for complex work
            if isDeepWork {
                return (40, "Poor Timing", .red)
            } else if isMeeting {
                return (70, "Acceptable", .yellow)
            } else {
                return (65, "Okay Timing", .yellow)
            }
        } else if hour >= 16 && hour < 19 {
            // Afternoon recovery - good for creative/meetings
            if isCreative || isMeeting {
                return (85, "Great Timing", .green)
            } else if isDeepWork {
                return (65, "Not Ideal", .yellow)
            } else {
                return (75, "Good Timing", .blue)
            }
        } else if hour >= 6 && hour < 9 {
            // Early morning - good energy
            if isDeepWork {
                return (80, "Good Timing", .blue)
            } else {
                return (70, "Decent Timing", .blue)
            }
        } else {
            // Evening/night
            if isDeepWork {
                return (50, "Low Energy Time", .orange)
            } else {
                return (60, "Evening Slot", .yellow)
            }
        }
    }

    var durationQuality: (score: Int, label: String, color: Color) {
        let duration = task.duration
        let category = task.category.lowercased()

        let isDeepWork = category.contains("work") || category.contains("coding") || category.contains("focus")
        let isMeeting = category.contains("meeting")
        let isExercise = category.contains("gym") || category.contains("exercise") || category.contains("workout")

        if isDeepWork {
            if duration >= 1.5 && duration <= 3.0 {
                return (90, "Ideal Duration", .green)
            } else if duration >= 0.5 && duration < 1.5 {
                return (60, "Too Short", .yellow)
            } else if duration > 3.0 {
                return (65, "Consider Break", .yellow)
            } else {
                return (40, "Too Brief", .red)
            }
        } else if isMeeting {
            if duration <= 1.0 {
                return (85, "Efficient Length", .green)
            } else if duration <= 1.5 {
                return (70, "Acceptable", .blue)
            } else {
                return (50, "Too Long", .orange)
            }
        } else if isExercise {
            if duration >= 0.5 && duration <= 1.5 {
                return (90, "Perfect Length", .green)
            } else if duration < 0.5 {
                return (55, "Too Short", .yellow)
            } else {
                return (70, "Intense Session", .blue)
            }
        } else {
            if duration >= 0.25 && duration <= 2.0 {
                return (75, "Good Duration", .blue)
            } else {
                return (60, "Check Length", .yellow)
            }
        }
    }

    var contextQuality: (hasBreakBefore: Bool, hasBreakAfter: Bool, score: Int) {
        let sortedEvents = allEvents.sorted { $0.startHour < $1.startHour }
        guard let index = sortedEvents.firstIndex(where: { $0.id == task.id }) else {
            return (true, true, 100)
        }

        let prevEvent = index > 0 ? sortedEvents[index - 1] : nil
        let nextEvent = index < sortedEvents.count - 1 ? sortedEvents[index + 1] : nil

        let hasBreakBefore: Bool = {
            guard let prev = prevEvent else { return true }
            return task.startHour - prev.endHour >= 0.25 // 15+ min gap
        }()

        let hasBreakAfter: Bool = {
            guard let next = nextEvent else { return true }
            return next.startHour - task.endHour >= 0.25 // 15+ min gap
        }()

        let score: Int = {
            if hasBreakBefore && hasBreakAfter {
                return 95
            } else if hasBreakBefore || hasBreakAfter {
                return 70
            } else {
                return 45
            }
        }()

        return (hasBreakBefore, hasBreakAfter, score)
    }

    var overallScore: Int {
        let energyScore = energyAlignment.score
        let durationScore = durationQuality.score
        let contextScore = contextQuality.score

        return (energyScore + durationScore + contextScore) / 3
    }

    var body: some View {
        VStack(spacing: 16) {
            // Overall Quality Score
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 6)
                        .frame(width: 60, height: 60)

                    Circle()
                        .trim(from: 0, to: CGFloat(overallScore) / 100)
                        .stroke(scoreColor(overallScore), lineWidth: 6)
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(overallScore)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Text("Score")
                            .font(.system(size: 8))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    MetricRow(
                        icon: "clock.fill",
                        label: energyAlignment.label,
                        score: energyAlignment.score,
                        color: energyAlignment.color
                    )

                    MetricRow(
                        icon: "timer",
                        label: durationQuality.label,
                        score: durationQuality.score,
                        color: durationQuality.color
                    )

                    MetricRow(
                        icon: "pause.circle.fill",
                        label: contextLabel,
                        score: contextQuality.score,
                        color: scoreColor(contextQuality.score)
                    )
                }
            }

            // Mini Timeline Context
            TaskContextTimeline(task: task, allEvents: allEvents)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(scoreColor(overallScore).opacity(0.3), lineWidth: 1)
                )
        )
    }

    var contextLabel: String {
        let context = contextQuality
        if context.hasBreakBefore && context.hasBreakAfter {
            return "Good Buffer Time"
        } else if context.hasBreakBefore || context.hasBreakAfter {
            return "One Break Missing"
        } else {
            return "Back-to-Back Tasks"
        }
    }

    func scoreColor(_ score: Int) -> Color {
        if score >= 80 {
            return .green
        } else if score >= 60 {
            return .blue
        } else if score >= 40 {
            return .yellow
        } else {
            return .red
        }
    }
}

struct MetricRow: View {
    let icon: String
    let label: String
    let score: Int
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)
                .frame(width: 16)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.8))

            Spacer()

            Text("\(score)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(color)
        }
    }
}

struct TaskContextTimeline: View {
    let task: DayEvent
    let allEvents: [DayEvent]

    var surroundingEvents: [DayEvent] {
        let sorted = allEvents.sorted { $0.startHour < $1.startHour }
        guard let index = sorted.firstIndex(where: { $0.id == task.id }) else {
            return [task]
        }

        let start = max(0, index - 1)
        let end = min(sorted.count - 1, index + 1)
        return Array(sorted[start...end])
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Schedule Context")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background timeline
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 40)

                    // Events
                    ForEach(surroundingEvents) { event in
                        let isCurrentTask = event.id == task.id
                        let xPosition = calculatePosition(for: event.startHour, in: geometry.size.width)
                        let width = calculateWidth(for: event.duration, in: geometry.size.width)

                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isCurrentTask ? Color.cyan : event.color.opacity(0.6))
                                .frame(width: width, height: isCurrentTask ? 36 : 28)
                                .overlay(
                                    Text(formatTime(event.startHour))
                                        .font(.system(size: isCurrentTask ? 10 : 8, weight: .semibold))
                                        .foregroundColor(.white)
                                )

                            if isCurrentTask {
                                Image(systemName: "arrowtriangle.up.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.cyan)
                            }
                        }
                        .offset(x: xPosition, y: isCurrentTask ? -2 : 2)
                    }
                }
            }
            .frame(height: 50)
        }
    }

    func calculatePosition(for hour: Double, in width: CGFloat) -> CGFloat {
        let minHour = surroundingEvents.map { $0.startHour }.min() ?? 0
        let maxHour = surroundingEvents.map { $0.endHour }.max() ?? 24
        let range = maxHour - minHour

        let ratio = (hour - minHour) / range
        return width * CGFloat(ratio)
    }

    func calculateWidth(for duration: Double, in totalWidth: CGFloat) -> CGFloat {
        let minHour = surroundingEvents.map { $0.startHour }.min() ?? 0
        let maxHour = surroundingEvents.map { $0.endHour }.max() ?? 24
        let range = maxHour - minHour

        let ratio = duration / range
        return max(40, totalWidth * CGFloat(ratio))
    }

    func formatTime(_ hour: Double) -> String {
        let h = Int(hour)
        let period = h >= 12 ? "PM" : "AM"
        let displayHour = h > 12 ? h - 12 : (h == 0 ? 12 : h)
        return "\(displayHour)\(period)"
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        TaskVisualInsight(
            task: DayEvent(
                title: "Gym Session",
                startHour: 18.0,
                endHour: 18.75,
                color: .red,
                category: "Health",
                emoji: "💪",
                description: "Workout at the gym",
                participants: [],
                isCompleted: false
            ),
            allEvents: [
                DayEvent(
                    title: "Deep Work",
                    startHour: 9.0,
                    endHour: 12.0,
                    color: .blue,
                    category: "Work",
                    emoji: "💻",
                    description: "Focus time",
                    participants: [],
                    isCompleted: false
                ),
                DayEvent(
                    title: "Gym Session",
                    startHour: 18.0,
                    endHour: 18.75,
                    color: .red,
                    category: "Health",
                    emoji: "💪",
                    description: "Workout",
                    participants: [],
                    isCompleted: false
                ),
                DayEvent(
                    title: "Dinner",
                    startHour: 20.0,
                    endHour: 21.0,
                    color: .orange,
                    category: "Personal",
                    emoji: "🍽️",
                    description: "Family dinner",
                    participants: [],
                    isCompleted: false
                )
            ]
        )
        .padding()
    }
}
