//
//  FocusBlocksView.swift
//  DayRhythm AI
//
//  Created by Claude on 31/10/25.
//

import SwiftUI

struct FocusBlocksView: View {
    let focusBlocks: [FocusBlock]

    var totalFocusTime: Double {
        focusBlocks.reduce(0) { $0 + $1.duration }
    }

    var excellentBlocks: Int {
        focusBlocks.filter { $0.quality == "excellent" }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Focus Blocks")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))

                    Text("\(String(format: "%.1f", totalFocusTime))h total • \(excellentBlocks) deep blocks")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.4))
                }

                Spacer()
            }

            if focusBlocks.isEmpty {
                Text("No focus blocks found")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                // Timeline visualization
                GeometryReader { geometry in
                    VStack(spacing: 4) {
                        ForEach(focusBlocks) { block in
                            FocusBlockBar(block: block, totalWidth: geometry.size.width)
                        }
                    }
                }
                .frame(height: CGFloat(focusBlocks.count * 44))

                // Legend
                HStack(spacing: 12) {
                    QualityLabel(quality: "excellent", label: "Deep (90+ min)", color: .green)
                    QualityLabel(quality: "good", label: "Good (30-90 min)", color: .blue)
                    QualityLabel(quality: "fragmented", label: "Short (<30 min)", color: .orange)
                }
                .font(.system(size: 9))
                .padding(.top, 8)
            }
        }
    }
}

struct FocusBlockBar: View {
    let block: FocusBlock
    let totalWidth: CGFloat

    var qualityColor: Color {
        switch block.quality.lowercased() {
        case "excellent":
            return .green
        case "good":
            return .blue
        default:
            return .orange
        }
    }

    var barWidth: CGFloat {
        // Scale duration to fit width (max 3 hours = full width)
        let maxDuration: Double = 3.0
        let ratio = min(block.duration / maxDuration, 1.0)
        return totalWidth * CGFloat(ratio)
    }

    var body: some View {
        HStack(spacing: 8) {
            // Time label
            Text(formatTime(block.startTime))
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 50, alignment: .leading)

            // Bar
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: totalWidth - 120, height: 32)

                // Focus block bar
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [qualityColor.opacity(0.8), qualityColor.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: barWidth - 70, height: 32)
                    .overlay(
                        HStack {
                            Text(block.title)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .padding(.leading, 8)

                            Spacer()

                            if block.hasBreakAfter {
                                Image(systemName: "pause.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.trailing, 8)
                            }
                        }
                    )
            }

            // Duration label
            Text(formatDuration(block.duration))
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(qualityColor)
                .frame(width: 50, alignment: .trailing)
        }
    }

    private func formatTime(_ hour: Double) -> String {
        let h = Int(hour)
        let m = Int((hour - Double(h)) * 60)
        return String(format: "%d:%02d", h > 12 ? h - 12 : (h == 0 ? 12 : h), m)
    }

    private func formatDuration(_ duration: Double) -> String {
        let hours = Int(duration)
        let minutes = Int((duration - Double(hours)) * 60)
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct QualityLabel: View {
    let quality: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 12, height: 8)
            Text(label)
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        FocusBlocksView(focusBlocks: [
            FocusBlock(
                title: "Deep Work - Coding",
                startTime: 9.0,
                duration: 2.5,
                quality: "excellent",
                hasBreakAfter: true,
                category: "Work"
            ),
            FocusBlock(
                title: "Team Meeting",
                startTime: 11.5,
                duration: 1.0,
                quality: "good",
                hasBreakAfter: false,
                category: "Meeting"
            ),
            FocusBlock(
                title: "Quick Email Check",
                startTime: 12.5,
                duration: 0.25,
                quality: "fragmented",
                hasBreakAfter: true,
                category: "Admin"
            ),
            FocusBlock(
                title: "Design Review",
                startTime: 14.0,
                duration: 1.5,
                quality: "excellent",
                hasBreakAfter: false,
                category: "Creative"
            )
        ])
        .padding()
    }
}
