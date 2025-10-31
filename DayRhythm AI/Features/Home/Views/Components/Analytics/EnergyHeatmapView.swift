//
//  EnergyHeatmapView.swift
//  DayRhythm AI
//
//  Created by Claude on 31/10/25.
//

import SwiftUI

struct EnergyHeatmapView: View {
    let heatmapData: [EnergyHeatmapItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Energy Alignment")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))

            if heatmapData.isEmpty {
                Text("No tasks to analyze")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(heatmapData) { item in
                        EnergyHeatmapRow(item: item)
                    }
                }
            }

            // Legend
            HStack(spacing: 16) {
                LegendItem(color: .green, label: "Optimal")
                LegendItem(color: .yellow, label: "Good")
                LegendItem(color: .red, label: "Poor")
            }
            .font(.system(size: 10))
            .padding(.top, 8)
        }
    }
}

struct EnergyHeatmapRow: View {
    let item: EnergyHeatmapItem

    var alignmentColor: Color {
        switch item.alignment.lowercased() {
        case "optimal":
            return .green
        case "poor":
            return .red
        default:
            return .yellow
        }
    }

    var alignmentIcon: String {
        switch item.alignment.lowercased() {
        case "optimal":
            return "checkmark.circle.fill"
        case "poor":
            return "exclamationmark.triangle.fill"
        default:
            return "minus.circle.fill"
        }
    }

    var taskTypeIcon: String {
        switch item.actualTaskType {
        case "deep-work":
            return "brain.head.profile"
        case "meetings":
            return "person.3.fill"
        case "admin":
            return "doc.text.fill"
        case "creative":
            return "paintpalette.fill"
        default:
            return "circle.fill"
        }
    }

    var energyLabel: String {
        switch item.optimalEnergy.lowercased() {
        case "high":
            return "Peak Energy"
        case "medium":
            return "Good Energy"
        default:
            return "Low Energy"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Time indicator
            VStack(alignment: .leading, spacing: 2) {
                Text(formatTime(item.startTime))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                Text(energyLabel)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(width: 70, alignment: .leading)

            // Task info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: taskTypeIcon)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.7))

                    Text(item.title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }

                Text(item.category)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Alignment status
            HStack(spacing: 4) {
                Image(systemName: alignmentIcon)
                    .font(.system(size: 12))
                    .foregroundColor(alignmentColor)

                Text(item.alignment.capitalized)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(alignmentColor)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(alignmentColor.opacity(0.2))
            )
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(alignmentColor.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func formatTime(_ hour: Double) -> String {
        let h = Int(hour)
        let m = Int((hour - Double(h)) * 60)
        let period = h >= 12 ? "PM" : "AM"
        let displayHour = h > 12 ? h - 12 : (h == 0 ? 12 : h)
        return String(format: "%d:%02d %@", displayHour, m, period)
    }
}

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        EnergyHeatmapView(heatmapData: [
            EnergyHeatmapItem(
                title: "Deep Work Session",
                startTime: 9.0,
                endTime: 11.0,
                optimalEnergy: "high",
                actualTaskType: "deep-work",
                alignment: "optimal",
                category: "Work"
            ),
            EnergyHeatmapItem(
                title: "Afternoon Meeting",
                startTime: 15.0,
                endTime: 16.0,
                optimalEnergy: "low",
                actualTaskType: "meetings",
                alignment: "poor",
                category: "Meeting"
            ),
            EnergyHeatmapItem(
                title: "Email Processing",
                startTime: 16.5,
                endTime: 17.0,
                optimalEnergy: "medium",
                actualTaskType: "admin",
                alignment: "good",
                category: "Admin"
            )
        ])
        .padding()
    }
}
