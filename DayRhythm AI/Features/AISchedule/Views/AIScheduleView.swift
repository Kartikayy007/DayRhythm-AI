
//
//  AIScheduleView.swift
//  DayRhythm AI
//
//  Created by kartikay on 25/10/25.
//



import SwiftUI

struct AIScheduleView: View {
    @StateObject private var aiViewModel = AIScheduleViewModel()
    @ObservedObject var homeViewModel: HomeViewModel
    @FocusState private var isTextEditorFocused: Bool

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning!"
        case 12..<17: return "Good afternoon!"
        case 17..<22: return "Good evening!"
        default: return "Hi there!"
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(greeting)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(red: 0.95, green: 0.65, blue: 0.65))

                    Text("What tasks need your attention today?")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 30)

                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        if let error = aiViewModel.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(.red)

                                Text(error)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.red)

                                Spacer()
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.1))
                            )
                            .padding(.horizontal, 20)
                        }

                        
                        if !aiViewModel.parsedTasks.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Generated Tasks (\(aiViewModel.parsedTasks.count))")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.6))

                                    Spacer()

                                    if aiViewModel.parsedTasks.count > 1 {
                                        Button(action: {
                                            for task in aiViewModel.parsedTasks {
                                                aiViewModel.addTaskToSchedule(task, to: homeViewModel)
                                            }
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.system(size: 12))
                                                Text("Add All")
                                                    .font(.system(size: 12, weight: .semibold))
                                            }
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(Color.white)
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)

                                VStack(spacing: 12) {
                                    ForEach(aiViewModel.parsedTasks) { task in
                                        TaskPreviewCard(task: task, viewModel: aiViewModel, homeViewModel: homeViewModel)
                                            .padding(.horizontal, 20)
                                    }
                                }
                            }
                        } else {
                            
                            VStack(spacing: 16) {
                                Text("Try asking:")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.5))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                VStack(spacing: 12) {
                                    SuggestionCard(
                                        icon: "calendar",
                                        text: "Team meeting tomorrow at 3pm for 1 hour",
                                        action: {
                                            aiViewModel.userInput = "Team meeting tomorrow at 3pm for 1 hour"
                                        }
                                    )

                                    SuggestionCard(
                                        icon: "laptopcomputer",
                                        text: "Schedule 2 hours coding in the morning",
                                        action: {
                                            aiViewModel.userInput = "Schedule 2 hours coding in the morning"
                                        }
                                    )

                                    SuggestionCard(
                                        icon: "fork.knife",
                                        text: "Add lunch break at 12:30pm",
                                        action: {
                                            aiViewModel.userInput = "Add lunch break at 12:30pm"
                                        }
                                    )

                                    SuggestionCard(
                                        icon: "dumbbell",
                                        text: "Gym session at 6pm for 45 minutes",
                                        action: {
                                            aiViewModel.userInput = "Gym session at 6pm for 45 minutes"
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 40)
                        }

                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.top, 10)
                }

                
                HStack(spacing: 16) {
                    
                    Button(action: {
                        
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }

                    
                    Button(action: {
                        
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }

                    
                    TextField("Add tasks with AI...", text: $aiViewModel.userInput)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.white)
                        .focused($isTextEditorFocused)
                        .submitLabel(.send)
                        .onSubmit {
                            if !aiViewModel.userInput.isEmpty {
                                isTextEditorFocused = false
                                aiViewModel.parseTask()
                            }
                        }

                    Spacer()

                    
                    Button(action: {
                        
                    }) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }

                    
                    Button(action: {
                        if !aiViewModel.userInput.isEmpty {
                            isTextEditorFocused = false
                            aiViewModel.parseTask()
                        }
                    }) {
                        if aiViewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else if !aiViewModel.userInput.isEmpty {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color(red: 0.95, green: 0.65, blue: 0.65))
                        } else {
                            Image(systemName: "waveform")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .disabled(aiViewModel.isLoading)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isTextEditorFocused = false
                }
                .foregroundColor(.white)
            }
        }
    }
}

struct TaskPreviewCard: View {
    let task: ParsedTaskUI
    let viewModel: AIScheduleViewModel
    let homeViewModel: HomeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Text(task.emoji)
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text(task.description)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                }

                Spacer()

                Button(action: {
                    viewModel.removeTask(task)
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.4))
                }
            }

            HStack(spacing: 8) {
                Label(task.timeString, systemImage: "clock")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))

                Divider()

                Label(task.durationString, systemImage: "hourglass")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }

            Button(action: {
                viewModel.addTaskToSchedule(task, to: homeViewModel)
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 14, weight: .semibold))

                    Text("Add to Schedule")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: task.colorHex) ?? Color.white)
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct SuggestionCard: View {
    let icon: String
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.95, green: 0.65, blue: 0.65))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color(red: 0.95, green: 0.65, blue: 0.65).opacity(0.15))
                    )

                Text(text)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AIScheduleView(homeViewModel: HomeViewModel())
}
