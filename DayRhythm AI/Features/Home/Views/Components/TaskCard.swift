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
        HStack(alignment: .top, spacing: 0) {
            
            VStack(alignment: .leading, spacing: 4) {
                
                if !isCompleted {
                    Text(timeString)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(textColor.opacity(0.7))
                }

                
                HStack(spacing: 8) {
                    Text(emoji)
                        .font(.system(size: 20))

                    Text(title)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(textColor)
                }

                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(textColor.opacity(0.7))
                    .lineLimit(2)

                
                if !isCompleted {
                    HStack(spacing: 8) {
                        Text("Today")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(textColor.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(textColor.opacity(0.15))
                            )

                        Text(duration)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(textColor.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(textColor.opacity(0.15))
                            )
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.leading, 20)
            .padding(.vertical, 20)

            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 26)
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
