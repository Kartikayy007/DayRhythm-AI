//
//  TaskCard.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI

struct TaskCard: View {
    let title: String
    let description: String
    let timeString: String
    let duration: String
    let color: Color
    let emoji: String
    let isCompleted: Bool
    let participants: [String]
    var onTap: (() -> Void)? = nil

    var textColor: Color {
        return .black
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 12) {
                if !isCompleted {
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(textColor.opacity(0.6))

                        Text(timeString)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(textColor.opacity(0.7))
                    }
                }

                HStack(spacing: 8) {
                    Text(emoji)
                        .font(.system(size: 32))

                    Text(title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(textColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(description)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(textColor.opacity(0.6))
                    .lineLimit(2)

                if !isCompleted {
                    HStack(spacing: 8) {
                        Text("Today")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(textColor.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(textColor.opacity(0.12))
                            )

                        Text(duration)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(textColor.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(textColor.opacity(0.12))
                            )
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)

            Circle()
                .fill(textColor.opacity(0.08))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(textColor.opacity(0.6))
                )
                .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.white)
        )
        .onTapGesture {
            onTap?()
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        TaskCard(
            title: "Team Meeting",
            description: "Discussing the project with the team",
            timeString: "",
            duration: "",
            color: Color(red: 255/255, green: 215/255, blue: 143/255),
            emoji: "📅",
            isCompleted: true,
            participants: []
        )

        TaskCard(
            title: "One-to-one",
            description: "Repeats every two weeks",
            timeString: "12:00–1:00 PM",
            duration: "1 h",
            color: .white,
            emoji: "👥",
            isCompleted: false,
            participants: ["Emma", "David"]
        )

        TaskCard(
            title: "PM Meeting",
            description: "Discussion of tasks for the month",
            timeString: "1:00–2:30 PM",
            duration: "1 h 30m",
            color: .white,
            emoji: "💼",
            isCompleted: false,
            participants: ["Lisa", "Tom", "Rachel", "Alex", "Sam", "Chris", "Pat"]
        )
    }
    .background(Color.black)
}
