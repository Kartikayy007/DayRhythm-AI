//
//  TimelineBarChart.swift
//  DayRhythm AI
//
//  Created by kartikay on 25/10/25.
//

import SwiftUI

struct TimelineBarChart: View {
    let hourlyData: [HourData]
    @State private var selectedHour: Int? = nil
    @State private var animationProgress: CGFloat = 0

    struct HourData: Identifiable {
        let id = UUID()
        let hour: Int
        let intensity: Double // 0.0 to 1.0 (free to fully booked)
        let color: Color
        let taskName: String?
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text("24-Hour Timeline")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))

            // Chart
            GeometryReader { geometry in
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(0..<24) { hour in
                        let data = hourlyData.first(where: { $0.hour == hour })
                        let intensity = data?.intensity ?? 0.0

                        VStack(spacing: 0) {
                            // Bar
                            RoundedRectangle(cornerRadius: 2)
                                .fill(barColor(for: hour, data: data))
                                .frame(width: (geometry.size.width - 46) / 24)
                                .frame(height: max(4, intensity * 80 * animationProgress))
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedHour = selectedHour == hour ? nil : hour
                                    }
                                }

                            // Hour label (show every 3 hours)
                            if hour % 3 == 0 {
                                Text("\(hour)")
                                    .font(.system(size: 8))
                                    .foregroundColor(.white.opacity(0.4))
                                    .frame(height: 12)
                            } else {
                                Color.clear
                                    .frame(height: 12)
                            }
                        }
                    }
                }
                .frame(height: 100)
            }
            .frame(height: 100)

            // Selected hour detail
            if let hour = selectedHour,
               let data = hourlyData.first(where: { $0.hour == hour }) {
                HStack {
                    Text("\(hour):00")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)

                    if let taskName = data.taskName {
                        Text("• \(taskName)")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        Text("• Free")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.green.opacity(0.7))
                    }

                    Spacer()
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.05))
                )
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
    }

    private func barColor(for hour: Int, data: HourData?) -> Color {
        if selectedHour == hour {
            return (data?.color ?? .gray).opacity(1.0)
        }

        if let data = data {
            return data.color.opacity(0.6)
        }

        // Free time
        return Color.white.opacity(0.1)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        TimelineBarChart(hourlyData: [
            .init(hour: 9, intensity: 1.0, color: .blue, taskName: "Deep Work"),
            .init(hour: 10, intensity: 0.8, color: .blue, taskName: "Coding"),
            .init(hour: 11, intensity: 1.0, color: .orange, taskName: "Meeting"),
            .init(hour: 12, intensity: 0.5, color: .green, taskName: "Lunch"),
            .init(hour: 13, intensity: 0.3, color: .green, taskName: "Break"),
            .init(hour: 14, intensity: 1.0, color: .blue, taskName: "Coding"),
            .init(hour: 15, intensity: 1.0, color: .blue, taskName: "Coding"),
            .init(hour: 16, intensity: 0.5, color: .purple, taskName: "Review")
        ])
        .padding()
    }
}