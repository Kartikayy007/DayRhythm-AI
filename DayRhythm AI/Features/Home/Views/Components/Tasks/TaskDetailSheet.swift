//
//  TaskDetailSheet.swift
//  DayRhythm AI
//
//  Created by kartikay on 24/10/25.
//

import SwiftUI

struct TaskDetailSheet: View {
    let task: DayEvent
    let allEvents: [DayEvent]
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showDeleteConfirm = false
    @State private var showEditSheet = false
    @State private var shouldRefreshTask = false

    var refreshedTask: DayEvent {
        // Try to get the latest version from viewModel
        return viewModel.events.first(where: { $0.id == task.id }) ?? task
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
                    }.buttonStyle(.glass)

                    Spacer()

                    Button(action: {
                        showEditSheet = true
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 40, height: 40)
                    }.buttonStyle(.glass)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                ScrollView(.vertical, showsIndicators: false) {
                CircularDayDial(
                    events: allEvents,
                    selectedDate: Date(),
                    highlightedEventId: task.id
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 20)

                    VStack(alignment: .leading, spacing: 16) {
                        Text(task.timeString)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.15))
                            )
                            .frame(maxWidth: .infinity, alignment: .center)

                        // Task Title
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)

                            Text(task.description)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)

                        // Duration and Category
                        VStack(spacing: 12) {
                            HStack {
                                Text("Duration")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.white.opacity(0.6))

                                Spacer()

                                Text(task.durationString)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Divider()
                                .background(Color.white.opacity(0.1))

                            HStack {
                                Text("Category")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.white.opacity(0.6))

                                Spacer()

                                Text(task.category)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                        )
                        .padding(.horizontal, 20)

                        // Delete Button
                        Button(action: {
                            showDeleteConfirm = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Delete Task")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.1))
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .alert("Delete Task?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                viewModel.deleteEvent(task)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
        .sheet(isPresented: $showEditSheet) {
            EditTaskSheet(
                originalTask: task,
                viewModel: viewModel,
                onUpdateComplete: {
                    // Close edit sheet and refresh
                    showEditSheet = false
                    shouldRefreshTask.toggle()
                }
            )
        }
        .onChange(of: shouldRefreshTask) { _ in
            // Dial will update automatically as the task reference changes
        }
    }
}

#Preview {
    TaskDetailSheet(
        task: DayEvent(
            title: "Team Meeting",
            startHour: 10,
            duration: 1.5,
            color: Color(red: 255/255, green: 215/255, blue: 143/255),
            category: "Work",
            emoji: "👥",
            description: "Discussing project progress",
            participants: [],
            isCompleted: false
        ),
        allEvents: [
            DayEvent(
                title: "Team Meeting",
                startHour: 10,
                duration: 1.5,
                color: Color(red: 255/255, green: 215/255, blue: 143/255),
                category: "Work",
                emoji: "👥",
                description: "Discussing project progress",
                participants: [],
                isCompleted: false
            ),
            DayEvent(
                title: "Deep Work",
                startHour: 9,
                duration: 3,
                color: .blue,
                category: "Work",
                emoji: "💻",
                description: "Focus time",
                participants: [],
                isCompleted: false
            )
        ],
        viewModel: HomeViewModel()
    )
}
