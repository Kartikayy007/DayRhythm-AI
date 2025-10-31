//
//  WorkLifeBalanceGauge.swift
//  DayRhythm AI
//
//  Created by Claude on 31/10/25.
//

import SwiftUI

struct WorkLifeBalanceGauge: View {
    let balance: WorkLifeBalance
    @State private var animationProgress: CGFloat = 0

    var scoreColor: Color {
        if balance.balanceScore >= 75 {
            return .green
        } else if balance.balanceScore >= 50 {
            return .yellow
        } else {
            return .red
        }
    }

    var scoreLabel: String {
        if balance.balanceScore >= 75 {
            return "Excellent"
        } else if balance.balanceScore >= 50 {
            return "Good"
        } else {
            return "Needs Improvement"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Work-Life Balance")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))

            HStack(spacing: 20) {
                // Gauge
                ZStack {
                    // Background arc
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(Color.white.opacity(0.1), lineWidth: 20)
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(135))

                    // Score arc
                    Circle()
                        .trim(from: 0, to: 0.75 * animationProgress * CGFloat(balance.balanceScore) / 100)
                        .stroke(
                            LinearGradient(
                                colors: [scoreColor.opacity(0.5), scoreColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(135))
                        .animation(.easeOut(duration: 1.0), value: animationProgress)

                    // Center content
                    VStack(spacing: 4) {
                        Text("\(balance.balanceScore)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)

                        Text(scoreLabel)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(scoreColor)

                        Text("Balance Score")
                            .font(.system(size: 8))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }

                // Category breakdown
                VStack(alignment: .leading, spacing: 10) {
                    CategoryBar(
                        label: "Work",
                        percentage: balance.workPercentage,
                        hours: balance.work,
                        color: .blue,
                        animationProgress: animationProgress
                    )
                    CategoryBar(
                        label: "Personal",
                        percentage: balance.personalPercentage,
                        hours: balance.personal,
                        color: .purple,
                        animationProgress: animationProgress
                    )
                    CategoryBar(
                        label: "Health",
                        percentage: balance.healthPercentage,
                        hours: balance.health,
                        color: .green,
                        animationProgress: animationProgress
                    )
                    CategoryBar(
                        label: "Other",
                        percentage: balance.otherPercentage,
                        hours: balance.other,
                        color: .orange,
                        animationProgress: animationProgress
                    )
                }
                .frame(maxWidth: .infinity)
            }

            // Ideal balance reference
            HStack {
                Text("Ideal: 60% Work • 25% Personal • 15% Health")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.4))
                Spacer()
            }
        }
        .onAppear {
            withAnimation {
                animationProgress = 1.0
            }
        }
    }
}

struct CategoryBar: View {
    let label: String
    let percentage: Int
    let hours: Double
    let color: Color
    let animationProgress: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))

                Spacer()

                Text("\(percentage)%")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(color)

                Text("(\(String(format: "%.1f", hours))h)")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.5))
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))

                    // Progress bar
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.8), color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(percentage) / 100 * animationProgress)
                        .animation(.easeOut(duration: 0.8), value: animationProgress)
                }
            }
            .frame(height: 6)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        WorkLifeBalanceGauge(balance: WorkLifeBalance(
            work: 6.0,
            personal: 2.0,
            health: 1.0,
            other: 0.5,
            workPercentage: 63,
            personalPercentage: 21,
            healthPercentage: 11,
            otherPercentage: 5,
            balanceScore: 82
        ))
        .padding()
    }
}
