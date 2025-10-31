
//
//  AIScheduleView.swift
//  DayRhythm AI
//
//  Created by kartikay on 25/10/25.
//



import SwiftUI
import Combine


struct TypewriterText: View {
    let text: String
    @State private var animatedText = ""
    @State private var charIndex = 0
    @State private var isVisible = true

    var body: some View {
        Text(animatedText)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(.white)
            .opacity(isVisible ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: isVisible)
            .onAppear {
                animateText()
            }
            .onChange(of: text) { _ in
                
                isVisible = false

                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    charIndex = 0
                    animatedText = ""
                    isVisible = true
                    animateText()
                }
            }
    }

    private func animateText() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true) { timer in
                if charIndex < text.count {
                    let index = text.index(text.startIndex, offsetBy: charIndex)
                    animatedText.append(text[index])
                    charIndex += 1
                } else {
                    timer.invalidate()
                }
            }
        }
    }
}

struct AIScheduleView: View {
    @StateObject private var aiViewModel = AIScheduleViewModel()
    @ObservedObject var homeViewModel: HomeViewModel
    @EnvironmentObject var appState: AppState
    @FocusState private var isTextEditorFocused: Bool
    @State private var currentGreetingIndex = Int.random(in: 0..<10)
    @State private var showImagePicker = false

    var greetingMessages: [String] {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 0..<12:  
            return [
                "What tasks need your attention today?",
                "Ready to plan your perfect morning?",
                "Let's make today productive!",
                "What's your focus this morning?",
                "Time to create your ideal schedule!",
                "How shall we start your day?",
                "What are your morning priorities?",
                "Let's build your daily rhythm!",
                "Ready to seize the day?",
                "What would you like to accomplish?"
            ]
        case 12..<17: 
            return [
                "What's on your afternoon agenda?",
                "How can I help this afternoon?",
                "Ready to tackle the rest of your day?",
                "What's next on your schedule?",
                "Let's optimize your afternoon!",
                "What are your afternoon goals?",
                "Time to refresh your schedule!",
                "How's your day progressing?",
                "What tasks remain for today?",
                "Let's keep the momentum going!"
            ]
        case 17..<22: 
            return [
                "Planning for tomorrow already?",
                "Wrapping up today's tasks?",
                "How was your productive day?",
                "Ready to plan your evening?",
                "What's left for tonight?",
                "Time to wind down or push forward?",
                "Evening goals to accomplish?",
                "Let's finish strong today!",
                "Preparing for tomorrow?",
                "How can I help this evening?"
            ]
        default:      
            return [
                "Burning the midnight oil?",
                "Late night productivity mode?",
                "Planning for tomorrow?",
                "Can't sleep? Let's be productive!",
                "Night owl schedule planning?",
                "What's keeping you up?",
                "Let's organize tomorrow!",
                "Midnight thoughts to tasks?",
                "Ready for tomorrow's challenges?",
                "Late night planning session?"
            ]
        }
    }

    let timer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()

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

            if !appState.isAuthenticated {
                AuthenticationPromptView(
                    title: "Sign in to use AI features",
                    message: "Create an account or log in to unlock AI-powered task planning and intelligent scheduling",
                    icon: "sparkles"
                )
            } else {
                mainContent
            }
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(greeting)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.appPrimary)

                    TypewriterText(text: greetingMessages[currentGreetingIndex])
                        .frame(height: 30, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 30)
                .onReceive(timer) { _ in
                    withAnimation {
                        currentGreetingIndex = (currentGreetingIndex + 1) % greetingMessages.count
                    }
                }
                

                
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
                            
                            Spacer()
                                .frame(height: 100)
                        }

                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.top, 10)
                }

                VStack(spacing: 12) {
                    if aiViewModel.parsedTasks.isEmpty && aiViewModel.userInput.isEmpty && aiViewModel.selectedImage == nil {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                SuggestionPill(
                                    text: "Meeting at 3pm",
                                    action: {
                                        aiViewModel.userInput = "Team meeting tomorrow at 3pm for 1 hour"
                                    }
                                )

                                SuggestionPill(
                                    text: "Morning coding session",
                                    action: {
                                        aiViewModel.userInput = "Schedule 2 hours coding in the morning"
                                    }
                                )

                                SuggestionPill(
                                    text: "Lunch at 12:30",
                                    action: {
                                        aiViewModel.userInput = "Add lunch break at 12:30pm"
                                    }
                                )

                                SuggestionPill(
                                    text: "Gym at 6pm",
                                    action: {
                                        aiViewModel.userInput = "Gym session at 6pm for 45 minutes"
                                    }
                                )

                                SuggestionPill(
                                    text: "Review emails",
                                    action: {
                                        aiViewModel.userInput = "Review and respond to emails for 30 minutes"
                                    }
                                )

                                SuggestionPill(
                                    text: "Weekly planning",
                                    action: {
                                        aiViewModel.userInput = "Weekly planning session for 1 hour"
                                    }
                                )

                                SuggestionPill(
                                    text: "Coffee break",
                                    action: {
                                        aiViewModel.userInput = "Coffee break at 3:30pm for 15 minutes"
                                    }
                                )

                                SuggestionPill(
                                    text: "Project review",
                                    action: {
                                        aiViewModel.userInput = "Project review meeting at 4pm"
                                    }
                                )
                            }
                            .padding(.horizontal, 16)
                        }
                        .frame(height: 44)
                    }

                    // Image Preview
                    if let selectedImage = aiViewModel.selectedImage {
                        HStack(spacing: 12) {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Timetable Image")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)

                                Text("AI will analyze this image")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.white.opacity(0.6))
                            }

                            Spacer()

                            Button(action: {
                                aiViewModel.clearImage()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.appPrimary.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 16)
                    }

                    HStack(spacing: 12) {
                        TextField(aiViewModel.selectedImage != nil ? "Add context (optional)" : "Ask anything", text: $aiViewModel.userInput)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.white)
                            .focused($isTextEditorFocused)
                            .submitLabel(.send)
                            .onSubmit {
                                isTextEditorFocused = false
                                if aiViewModel.selectedImage != nil {
                                    aiViewModel.parseTaskFromImage()
                                } else if !aiViewModel.userInput.isEmpty {
                                    aiViewModel.parseTask()
                                }
                            }

                        Spacer()

                        // Plus button - opens image picker
                        Button(action: {
                            showImagePicker = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }

                        // Send button - sends image or text
                        Button(action: {
                            isTextEditorFocused = false
                            if aiViewModel.selectedImage != nil {
                                aiViewModel.parseTaskFromImage()
                            } else if !aiViewModel.userInput.isEmpty {
                                aiViewModel.parseTask()
                            }
                        }) {
                            if aiViewModel.isLoading {
                                ProgressView()
                                    .tint(Color.white)
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 28, weight: .regular))
                                    .foregroundColor((aiViewModel.userInput.isEmpty && aiViewModel.selectedImage == nil) ? .white.opacity(0.3) : Color.appPrimary)
                            }
                        }
                        .disabled(aiViewModel.isLoading || (aiViewModel.userInput.isEmpty && aiViewModel.selectedImage == nil))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                            )
                    )
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 20)
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(selectedImage: $aiViewModel.selectedImage)
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

struct SuggestionPill: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AIScheduleView(homeViewModel: HomeViewModel())
}
