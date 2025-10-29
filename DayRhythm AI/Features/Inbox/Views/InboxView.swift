//
//  InboxView.swift
//  DayRhythm AI
//
//  Inbox view showing only task cards for the selected day
//

import SwiftUI

struct InboxView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @StateObject private var viewModel: InboxViewModel

    @State private var selectedTask: DayEvent? = nil
    @State private var showCreateTask = false

    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
        self._viewModel = StateObject(wrappedValue: InboxViewModel(homeViewModel: homeViewModel))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                ExpandableTopHeader(homeViewModel: homeViewModel)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 5) {
                        if viewModel.todayEvents.isEmpty {
                            emptyStateView
                                .padding(.top, 100)
                        } else {
                            ForEach(viewModel.todayEvents) { event in
                                TaskCard(
                                    title: event.title,
                                    description: event.description,
                                    timeString: event.isCompleted ? "" : event.timeString,
                                    duration: event.durationString,
                                    color: event.color,
                                    emoji: event.emoji,
                                    isCompleted: event.isCompleted,
                                    participants: event.participants,
                                    onTap: {
                                        selectedTask = event
                                    }
                                )
                                .padding(.horizontal, 0)
                            }
                        }
                    }
                    .padding(.top, 5)
                    .padding(.bottom, 100)
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.todayEvents.count)
            }
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailSheet(
                task: task,
                allEvents: homeViewModel.events,
                viewModel: homeViewModel
            )
        }
        .sheet(isPresented: $showCreateTask) {
            CreateTaskSheet(viewModel: homeViewModel)
        }
        .onReceive(homeViewModel.$selectedDate) { newDate in
            viewModel.selectDate(newDate)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.3))

            Text("No tasks for this day")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.5))

            Text("Tap + to add a task")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.3))
        }
    }
}

#Preview {
    @Previewable @StateObject var viewModel = {
        let vm = HomeViewModel()

        let sampleEvents = [
            DayEvent(
                title: "Morning Workout",
                startHour: 7,
                endHour: 8,
                color: .red,
                category: "Health",
                emoji: "🏃",
                description: "Cardio and strength training",
                participants: [],
                isCompleted: false
            ),
            DayEvent(
                title: "Team Meeting",
                startHour: 10,
                endHour: 11,
                color: .blue,
                category: "Work",
                emoji: "👥",
                description: "Weekly sync with the team",
                participants: ["John", "Sarah", "Mike"],
                isCompleted: false
            ),
            DayEvent(
                title: "Lunch Break",
                startHour: 12.5,
                endHour: 13.5,
                color: .orange,
                category: "Break",
                emoji: "🍔",
                description: "Lunch break",
                participants: [],
                isCompleted: false
            ),
            DayEvent(
                title: "Coding Session",
                startHour: 14,
                endHour: 17,
                color: .purple,
                category: "Work",
                emoji: "💻",
                description: "Deep work on the new feature",
                participants: [],
                isCompleted: false
            ),
            DayEvent(
                title: "Gym",
                startHour: 18,
                endHour: 19.5,
                color: .green,
                category: "Health",
                emoji: "💪",
                description: "Evening workout session",
                participants: [],
                isCompleted: false
            ),
            DayEvent(
                title: "Reading",
                startHour: 21,
                endHour: 22,
                color: .cyan,
                category: "Personal",
                emoji: "📚",
                description: "Read 30 pages",
                participants: [],
                isCompleted: false
            )
        ]

        
        for event in sampleEvents {
            vm.addEvent(event)
        }

        return vm
    }()

    InboxView(homeViewModel: viewModel)
}
