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
    @State private var isArcDragging = false
    
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
                            highlightedEventId: viewModel.currentTaskId,
                            onEventTimeChange: { eventId, newStartHour, newEndHour in
                                if let event = viewModel.events.first(where: { $0.id == eventId }) {
                                    let updatedEvent = DayEvent(
                                        id: event.id,  
                                        title: event.title,
                                        startHour: newStartHour,
                                        endHour: newEndHour,
                                        color: event.color,
                                        category: event.category,
                                        emoji: event.emoji,
                                        description: event.description,
                                        participants: event.participants,
                                        isCompleted: event.isCompleted
                                    )
                                    viewModel.updateEvent(event, with: updatedEvent)
                                }
                            },
                            onEventTap: { event in
                                selectedTask = event
                            },
                            onDragStateChange: { isDragging in
                                isArcDragging = isDragging
                            }
                        )
                        .padding(.top, 40)
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    
                                    guard !isArcDragging else { return }

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
                        
                        TimelineCalendarView(
                            homeViewModel: viewModel,
                            onEventTap: { event in
                                selectedTask = event
                            }
                        )
                        .padding(.bottom, 100)
                        .padding(.top, 20)
                        
                    }
                }
                .scrollDisabled(isArcDragging)
            }


        }
        .sheet(item: $selectedTask) { task in
            TaskDetailSheet(
                task: task,
                allEvents: viewModel.events,
                viewModel: viewModel
            )
        }
    }
}
