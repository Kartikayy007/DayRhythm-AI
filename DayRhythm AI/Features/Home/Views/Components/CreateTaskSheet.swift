//
//  CreateTaskSheet.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI

struct CreateTaskSheet: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var selectedEmoji = "📅"
    @State private var selectedColor = Color(red: 255/255, green: 215/255, blue: 143/255)
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var repeatDaily = false

    let availableEmojis = ["📅", "👥", "💼", "🎯", "📊", "✏️", "🎨", "💻", "📱", "🏃", "🍔", "☕️", "🏠", "🎮", "📚", "🎵"]

    let availableColors = [
        Color(red: 255/255, green: 215/255, blue: 143/255),
        Color(red: 180/255, green: 200/255, blue: 255/255),
        Color(red: 255/255, green: 180/255, blue: 180/255),
        Color(red: 180/255, green: 255/255, blue: 180/255),
        Color(red: 255/255, green: 200/255, blue: 255/255)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }

                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))

                        TextField("", text: $title, prompt: Text("Task title").foregroundColor(.white.opacity(0.4)))
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .tint(.cyan)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                            )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))

                        TextField("", text: $description, prompt: Text("Add description").foregroundColor(.white.opacity(0.4)))
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                            .tint(.cyan)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                            )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Emoji")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(availableEmojis, id: \.self) { emoji in
                                    Button(action: {
                                        selectedEmoji = emoji
                                    }) {
                                        Text(emoji)
                                            .font(.system(size: 28))
                                            .frame(width: 50, height: 50)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(selectedEmoji == emoji ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedEmoji == emoji ? Color.white : Color.clear, lineWidth: 2)
                                            )
                                    }
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Color")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))

                        HStack(spacing: 12) {
                            ForEach(availableColors, id: \.self) { color in
                                Button(action: {
                                    selectedColor = color
                                }) {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                        )
                                }
                            }

                        }
                    }

                    // Time Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Time")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))

                        HStack(spacing: 16) {
                            DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .colorScheme(.dark)

                            Text("to")
                                .foregroundColor(.white.opacity(0.6))

                            DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .colorScheme(.dark)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                    }

                    HStack {
                        Text("Repeat Daily")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)

                        Spacer()

                        Toggle("", isOn: $repeatDaily)
                            .tint(selectedColor)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                    )

                    Spacer()

                    Button(action: createTask) {
                        Text("Create Task")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                            )
                    }
                }
                .padding()
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }

    private func createTask() {
        let calendar = Calendar.current
        let startHour = Double(calendar.component(.hour, from: startTime)) +
                       Double(calendar.component(.minute, from: startTime)) / 60
        let endHour = Double(calendar.component(.hour, from: endTime)) +
                     Double(calendar.component(.minute, from: endTime)) / 60
        let duration = endHour > startHour ? endHour - startHour : (24 - startHour + endHour)

        let newEvent = DayEvent(
            title: title.isEmpty ? "New Task" : title,
            startHour: startHour,
            duration: duration,
            color: selectedColor,
            category: "Custom",
            emoji: selectedEmoji,
            description: description,
            participants: [],
            isCompleted: false
        )

        viewModel.addEvent(newEvent, repeatDaily: repeatDaily)
        dismiss()
    }
}

#Preview {
    CreateTaskSheet(viewModel: HomeViewModel())
}
