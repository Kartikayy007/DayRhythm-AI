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
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var showDeleteConfirm = false
    @State private var showEditSheet = false
    @State private var shouldRefreshTask = false
    @State private var taskInsight: String = ""
    @State private var isLoadingInsight = false
    @State private var showLoginSheet = false
    @State private var showSignupSheet = false

    var refreshedTask: DayEvent {
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
                    }.glassEffect()

                    Spacer()

                    Button(action: {
                        showEditSheet = true
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 40, height: 40)
                    }.glassEffect()
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


                        if appState.isAuthenticated {
                            AIInsightView(
                                insight: taskInsight,
                                isLoading: isLoadingInsight
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        } else {
                            VStack(spacing: 12) {
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 14))
                                    Text("Sign in to see AI insights for this task")
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(.white.opacity(0.6))

                                Button(action: {
                                    showLoginSheet = true
                                }) {
                                    Text("Sign In")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        }

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
            CreateTaskSheet(
                viewModel: viewModel,
                existingTask: task,
                onUpdateComplete: {
                    showEditSheet = false
                    shouldRefreshTask.toggle()
                }
            )
        }
        .onChange(of: shouldRefreshTask) { _ in
        }
        .onAppear {
            guard appState.isAuthenticated else {
                return
            }
            Task {
                isLoadingInsight = true

                do {
                    let insight = try await BackendService.shared.getTaskInsight(task: task)
                    await MainActor.run {
                        taskInsight = insight
                        isLoadingInsight = false
                    }
                } catch {
                    
                    await MainActor.run {
                        taskInsight = "Insights temporarily unavailable"
                        isLoadingInsight = false
                    }
                }
            }
        }
        .sheet(isPresented: $showLoginSheet) {
            DarkLoginSheet()
        }
        .sheet(isPresented: $showSignupSheet) {
            DarkSignupSheet()
        }
    }
}

#Preview {
    TaskDetailSheet(
        task: DayEvent(
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
        allEvents: [
            DayEvent(
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
            DayEvent(
                title: "Deep Work",
                startHour: 9,
                endHour: 12,
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
