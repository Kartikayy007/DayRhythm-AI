//
//  HomeView.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showCreateTask = false
    @State private var selectedTask: DayEvent? = nil

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                TopHeader(homeViewModel: viewModel)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        CircularDayDial(
                            events: viewModel.events,
                            selectedDate: viewModel.selectedDate,
                            highlightedEventId: viewModel.currentTaskId
                        )
                        .padding(.top, 40)
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    if value.translation.width > 50 {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            viewModel.moveToPreviousDay()
                                        }
                                    } else if value.translation.width < -50 {
                                        // Swipe left - next day
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            viewModel.moveToNextDay()
                                        }
                                    }
                                }
                        )

                        VStack(spacing: 5) {
                            ForEach(viewModel.events) { event in
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
                            }
                        }
                        .animation(.easeInOut(duration: 0.3), value: viewModel.events.count)
                        .padding(.bottom, 100)
                        .padding(.top, 10)

                    }
                }
            }

            Button(action: {
                showCreateTask = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
            }
            .buttonStyle(.glass)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            .padding(.bottom, 30)
            .padding(.trailing, 20)
        }
        .sheet(isPresented: $showCreateTask) {
            CreateTaskSheet(viewModel: viewModel)
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailSheet(task: task, allEvents: viewModel.events, viewModel: viewModel)
        }
    }
}

#Preview {
    HomeView()
}
