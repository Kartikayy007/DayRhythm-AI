//
//  HomeView.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var showCreateTask = false
    @State private var selectedTask: DayEvent? = nil
    @State private var showDayInsights = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                ExpandableTopHeader(homeViewModel: viewModel)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        CircularDayDial(
                            events: viewModel.events,
                            selectedDate: viewModel.selectedDate,
                            highlightedEventId: viewModel.currentTaskId
                        )
                        .padding(.top, 40)
                        .onLongPressGesture(minimumDuration: 0.5) {
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.prepare()
                            impactFeedback.impactOccurred()
                            
                            // Show insights sheet
                            showDayInsights = true
                        }
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    if value.translation.width > 50 {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            viewModel.moveToPreviousDay()
                                        }
                                    } else if value.translation.width < -50 {
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


        }
        .sheet(item: $selectedTask) { task in
            TaskDetailSheet(
                task: task,
                allEvents: viewModel.events,
                viewModel: viewModel
            )
        }
        .sheet(isPresented: $showDayInsights) {
            DayInsightsSheet(homeViewModel: viewModel)
        }
    }
    
//    #Preview {
//            HomeView(viewModel: HomeViewModel())
//    }
}
