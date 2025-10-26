//
//  PieChartView.swift
//  DayRhythm AI
//
//  Created by kartikay on 25/10/25.
//

import SwiftUI

struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(center: center,
                   radius: radius,
                   startAngle: startAngle,
                   endAngle: endAngle,
                   clockwise: false)
        path.closeSubpath()

        return path
    }
}

struct PieChartView: View {
    let data: [ChartData]
    @State private var animationProgress: Double = 0

    struct ChartData: Identifiable {
        let id = UUID()
        let category: String
        let value: Double
        let color: Color
        let emoji: String
    }

    var total: Double {
        data.reduce(0) { $0 + $1.value }
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 200, height: 200)

            // Pie slices
            ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                PieSlice(
                    startAngle: startAngle(for: index),
                    endAngle: endAngle(for: index)
                )
                .fill(item.color.opacity(0.8))
                .scaleEffect(animationProgress)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.8)
                        .delay(Double(index) * 0.05),
                    value: animationProgress
                )
            }

            // Center circle for donut effect
            Circle()
                .fill(Color.black)
                .frame(width: 100, height: 100)

            // Center text
            VStack(spacing: 4) {
                Text("\(Int(total))h")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("Scheduled")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(width: 200, height: 200)
        .onAppear {
            withAnimation {
                animationProgress = 1.0
            }
        }
    }

    private func startAngle(for index: Int) -> Angle {
        guard total > 0 else { return .zero }

        let precedingTotal = data.prefix(index).reduce(0) { $0 + $1.value }
        return .degrees((precedingTotal / total) * 360 - 90)
    }

    private func endAngle(for index: Int) -> Angle {
        guard total > 0 else { return .zero }

        let precedingTotal = data.prefix(index + 1).reduce(0) { $0 + $1.value }
        return .degrees((precedingTotal / total) * 360 - 90)
    }
}

// Legend component
struct PieChartLegend: View {
    let data: [PieChartView.ChartData]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(data) { item in
                HStack(spacing: 8) {
                    Circle()
                        .fill(item.color)
                        .frame(width: 12, height: 12)

                    Text(item.emoji)
                        .font(.system(size: 14))

                    Text(item.category)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))

                    Spacer()

                    Text("\(String(format: "%.1f", item.value))h")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 20) {
            PieChartView(data: [
                .init(category: "Work", value: 4.5, color: .blue, emoji: "💻"),
                .init(category: "Meetings", value: 2.0, color: .orange, emoji: "👥"),
                .init(category: "Breaks", value: 1.0, color: .green, emoji: "☕"),
                .init(category: "Personal", value: 1.5, color: .purple, emoji: "🏃")
            ])

            PieChartLegend(data: [
                .init(category: "Work", value: 4.5, color: .blue, emoji: "💻"),
                .init(category: "Meetings", value: 2.0, color: .orange, emoji: "👥"),
                .init(category: "Breaks", value: 1.0, color: .green, emoji: "☕"),
                .init(category: "Personal", value: 1.5, color: .purple, emoji: "🏃")
            ])
            .padding()
        }
    }
}