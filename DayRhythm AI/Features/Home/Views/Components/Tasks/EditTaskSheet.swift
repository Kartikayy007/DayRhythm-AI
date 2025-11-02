//
//  EditTaskSheet.swift
//  DayRhythm AI
//
//  Created by kartikay on 24/10/25.
//

import SwiftUI

struct EditTaskSheet: View {
    let originalTask: DayEvent
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss
    var onUpdateComplete: (() -> Void)? = nil

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedEmoji: String = "📅"
    @State private var selectedColor: Color = Color.white
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date().addingTimeInterval(3600)

    let availableEmojis = ["📅", "👥", "💼", "🎯", "📊", "✏️", "🎨", "💻", "📱", "🏃", "🍔", "☕️", "🏠", "🎮", "📚", "🎵"]

    let availableColors = [
        Color(red: 255/255, green: 215/255, blue: 143/255),
        Color(red: 180/255, green: 200/255, blue: 255/255),
        Color(red: 255/255, green: 180/255, blue: 180/255),
        Color(red: 180/255, green: 255/255, blue: 180/255),
        Color(red: 255/255, green: 200/255, blue: 255/255)
    ]

    var previewEvent: DayEvent {
        let calendar = Calendar.current
        let startHour = Double(calendar.component(.hour, from: startTime)) +
                       Double(calendar.component(.minute, from: startTime)) / 60
        let endHourCalculated = Double(calendar.component(.hour, from: endTime)) +
                     Double(calendar.component(.minute, from: endTime)) / 60
        let endHour = endHourCalculated > startHour ? endHourCalculated : endHourCalculated + 24

        return DayEvent(
            title: title.isEmpty ? "New Task" : title,
            startHour: startHour,
            endHour: endHour,
            color: selectedColor,
            category: originalTask.category,
            emoji: selectedEmoji,
            description: description,
            participants: originalTask.participants,
            isCompleted: originalTask.isCompleted
        )
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 40, height: 40)
                    }.glassEffect()
                    Spacer()

                    Button(action: updateTask) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 40, height: 40)
                    }.glassEffect()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            ScrollView {

                
                CircularDayDial(
                    events: [previewEvent],
                    selectedDate: Date(),
                    highlightedEventId: previewEvent.id,
                    onEventTimeChange: { eventId, newStartHour, newEndHour in
                        var startComponents = Calendar.current.dateComponents([.year, .month, .day], from: startTime)
                        startComponents.hour = Int(newStartHour)
                        startComponents.minute = Int((newStartHour - Double(Int(newStartHour))) * 60)
                        if let newStart = Calendar.current.date(from: startComponents) {
                            startTime = newStart
                        }

                        var endComponents = Calendar.current.dateComponents([.year, .month, .day], from: endTime)
                        endComponents.hour = Int(newEndHour)
                        endComponents.minute = Int((newEndHour - Double(Int(newEndHour))) * 60)
                        if let newEnd = Calendar.current.date(from: endComponents) {
                            endTime = newEnd
                        }
                    }
                )
                .id("\(startTime)-\(endTime)-\(selectedColor)-\(selectedEmoji)")
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                ScrollView(.vertical, showsIndicators: false) {
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

                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(20)
                }
            }
        }
        .onAppear {
            title = originalTask.title
            description = originalTask.description
            selectedEmoji = originalTask.emoji
            selectedColor = originalTask.color

            
            var startComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            startComponents.hour = Int(originalTask.startHour)
            startComponents.minute = Int((originalTask.startHour - Double(Int(originalTask.startHour))) * 60)
            startTime = Calendar.current.date(from: startComponents) ?? Date()

            
            var endComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            endComponents.hour = Int(originalTask.endHour)
            endComponents.minute = Int((originalTask.endHour - Double(Int(originalTask.endHour))) * 60)
            endTime = Calendar.current.date(from: endComponents) ?? Date()
        }
    }
    }

    private func updateTask() {
        let calendar = Calendar.current
        let startHour = Double(calendar.component(.hour, from: startTime)) +
                       Double(calendar.component(.minute, from: startTime)) / 60
        let endHourCalculated = Double(calendar.component(.hour, from: endTime)) +
                     Double(calendar.component(.minute, from: endTime)) / 60
        let endHour = endHourCalculated > startHour ? endHourCalculated : endHourCalculated + 24

        let updatedEvent = DayEvent(
            title: title.isEmpty ? "New Task" : title,
            startHour: startHour,
            endHour: endHour,
            color: selectedColor,
            category: originalTask.category,
            emoji: selectedEmoji,
            description: description,
            participants: originalTask.participants,
            isCompleted: originalTask.isCompleted
        )

        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        let taskDate = formatter.date(from: originalTask.dateString) ?? viewModel.selectedDate

        viewModel.updateEvent(originalTask, with: updatedEvent, for: taskDate)
        onUpdateComplete?()
        dismiss()
    }
}

#Preview {
    EditTaskSheet(
        originalTask: DayEvent(
            title: "Team Meeting",
            startHour: 10,
            endHour: 11.5,
            color: Color(red: 255/255, green: 215/255, blue: 143/255),
            category: "Work",
            emoji: "👥",
            description: "Discussing project progress",
            participants: [],
            isCompleted: false
        ),
        viewModel: HomeViewModel()
    )
}
