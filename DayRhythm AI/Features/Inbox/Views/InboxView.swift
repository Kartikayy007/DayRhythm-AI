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
                    VStack(spacing: 12) {
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
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.top, 20)
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

    // Empty state view
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
    InboxView(homeViewModel: HomeViewModel())
}
