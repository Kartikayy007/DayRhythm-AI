//
//  CreateTaskSheet.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI

struct CreateTaskSheet: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss

    var existingTask: DayEvent? = nil  
    var onUpdateComplete: (() -> Void)? = nil  

    @State private var title = ""
    @State private var selectedEmoji = "🤞"
    @State private var selectedColor = [
        Color(hex: "#FF5733") ?? Color.red,
        Color(hex: "#33FF57") ?? Color.green,
        Color(hex: "#3357FF") ?? Color.blue,
        Color(hex: "#F333FF") ?? Color.purple,
        Color(hex: "#FF33A8") ?? Color.pink,
        Color(hex: "#33FFF5") ?? Color.cyan,
        Color(hex: "#FFD433") ?? Color.yellow,
        Color(hex: "#FF8C33") ?? Color.orange
    ].randomElement() ?? Color.appPrimary
    @State private var selectedDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(900)

    @State private var notificationEnabled = false
    @State private var notificationMinutes: [Int] = []
    @State private var repeatEnabled = false
    @State private var notes = ""

    @State private var showColorEmojiPicker = false
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @State private var showNotificationPicker = false
    @State private var showNotificationPermissionAlert = false
    @State private var showNotificationFailureAlert = false
    @State private var notificationErrorMessage = ""

    @FocusState private var isNotesFieldFocused: Bool
    @FocusState private var isTitleFieldFocused: Bool

    private var isEditMode: Bool {
        existingTask != nil
    }

    private var previewEvent: DayEvent {
        let calendar = Calendar.current
        let startHour = Double(calendar.component(.hour, from: startTime)) +
                       Double(calendar.component(.minute, from: startTime)) / 60
        let endHourCalculated = Double(calendar.component(.hour, from: endTime)) +
                     Double(calendar.component(.minute, from: endTime)) / 60
        let endHour = endHourCalculated > startHour ? endHourCalculated : endHourCalculated + 24

        return DayEvent(
            id: existingTask?.id ?? UUID(),
            title: title.isEmpty ? "New Task" : title,
            startHour: startHour,
            endHour: endHour,
            color: selectedColor,
            category: existingTask?.category ?? "Custom",
            emoji: selectedEmoji,
            description: notes,
            participants: existingTask?.participants ?? [],
            isCompleted: existingTask?.isCompleted ?? false,
            notificationSettings: NotificationSettings(
                enabled: notificationEnabled,
                minutesBefore: notificationMinutes,
                notificationIds: []
            )
        )
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM yyyy"
        return formatter.string(from: selectedDate)
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let start = formatter.string(from: startTime)
        let end = formatter.string(from: endTime)
        return "\(start)–\(end)"
    }

    private var durationString: String {
        let duration = endTime.timeIntervalSince(startTime)
        let minutes = Int(duration / 60)
        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if hours > 0 && remainingMinutes > 0 {
            return "\(hours)h \(remainingMinutes)min"
        } else if hours > 0 {
            return "\(hours) hr"
        } else {
            return "\(minutes) min"
        }
    }

    private var notificationTitle: String {
        guard notificationEnabled, !notificationMinutes.isEmpty else {
            return "No Alerts"
        }

        let sorted = notificationMinutes.sorted(by: >)
        if sorted.count == 1 {
            let mins = sorted[0]
            return mins == 0 ? "At time of event" : "\(mins) min before"
        } else {
            return "\(sorted.count) alerts"
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    .glassEffect()
                    Spacer()
                }
                .padding()

                ScrollView {
                    VStack(spacing: 24) {
                        
                        if isEditMode {
                            CircularDayDial(
                                events: [previewEvent],
                                selectedDate: selectedDate,
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
                            .padding(.bottom, 8)
                        }

                        ZStack {
                            CreateTaskPreviewCard(
                                title: $title,
                                emoji: selectedEmoji,
                                color: selectedColor,
                                startTime: startTime,
                                endTime: endTime,
                                isTitleFocused: $isTitleFieldFocused
                            )

                            HStack {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: 80)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        showColorEmojiPicker = true
                                    }

                                Spacer()
                            }
                        }


                        VStack(spacing: 0) {
                            OptionRow(
                                icon: "calendar",
                                title: dateString,
                                value: Calendar.current.isDateInToday(selectedDate) ? "Today" : "",
                                showChevron: true,
                                action: {
                                    showDatePicker = true
                                }
                            )

                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal)

                            OptionRow(
                                icon: "clock",
                                title: timeString,
                                value: durationString,
                                showChevron: true,
                                action: {
                                    showTimePicker = true
                                }
                            )

                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal)

                            OptionRow(
                                icon: "bell",
                                title: notificationEnabled ? notificationTitle : "No Alerts",
                                value: notificationEnabled ? "" : "Set notification",
                                showChevron: true,
                                action: {
                                    Task {
                                        await checkNotificationPermissionAndOpen()
                                    }
                                }
                            )

                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal)

                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.6))
                                    .frame(width: 24)

                                Text("Repeat")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)

                                Spacer()

                                Toggle("", isOn: $repeatEnabled)
                                    .tint(Color.appPrimary)
                            }
                            .padding()
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                        )

                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Add notes, meeting links or phone numbers...", text: $notes, axis: .vertical)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .tint(Color.appPrimary)
                                .lineLimit(3...6)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.05))
                                )
                                .focused($isNotesFieldFocused)
                        }

                    }
                    .padding(.horizontal)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: isEditMode ? updateTask : createTask) {
                Text(isEditMode ? "Save changes" : "Add to schedule")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appPrimary)
                    )
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0),
                        Color.black.opacity(0.8),
                        Color.black
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)
                .offset(y: -40)
            )
        }
        .sheet(isPresented: $showColorEmojiPicker) {
            ColorEmojiPickerSheet(
                selectedEmoji: $selectedEmoji,
                selectedColor: $selectedColor
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showTimePicker) {
            TimePickerSheet(
                startTime: $startTime,
                endTime: $endTime
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showNotificationPicker) {
            NotificationPickerSheet(
                isEnabled: $notificationEnabled,
                selectedMinutes: $notificationMinutes
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            if let task = existingTask {
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.timeZone = TimeZone.current
                if let taskDate = formatter.date(from: task.dateString) {
                    selectedDate = taskDate
                } else {
                    
                    selectedDate = viewModel.selectedDate
                }

                title = task.title
                notes = task.description
                selectedEmoji = task.emoji
                selectedColor = task.color

                var startComponents = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
                startComponents.hour = Int(task.startHour)
                startComponents.minute = Int((task.startHour - Double(Int(task.startHour))) * 60)
                startTime = Calendar.current.date(from: startComponents) ?? Date()

                var endComponents = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
                endComponents.hour = Int(task.endHour)
                endComponents.minute = Int((task.endHour - Double(Int(task.endHour))) * 60)
                endTime = Calendar.current.date(from: endComponents) ?? Date()

                notificationEnabled = task.notificationSettings.enabled
                notificationMinutes = task.notificationSettings.minutesBefore
            } else {
                
                selectedDate = viewModel.selectedDate

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTitleFieldFocused = true
                }
            }
        }
        .alert("Notification Permission Required", isPresented: $showNotificationPermissionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("To receive task reminders, please enable notifications in Settings.")
        }
        .alert("Notification Error", isPresented: $showNotificationFailureAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(notificationErrorMessage)
        }
    }

    private func updateTask() {
        guard let originalTask = existingTask else { return }

        let calendar = Calendar.current
        let startHour = Double(calendar.component(.hour, from: startTime)) +
                       Double(calendar.component(.minute, from: startTime)) / 60
        let endHourCalculated = Double(calendar.component(.hour, from: endTime)) +
                     Double(calendar.component(.minute, from: endTime)) / 60
        let endHour = endHourCalculated > startHour ? endHourCalculated : endHourCalculated + 24

        
        Task {
            await NotificationService.shared.cancelAllNotifications(for: originalTask.id)
        }

        
        let notificationSettings = NotificationSettings(
            enabled: notificationEnabled,
            minutesBefore: notificationMinutes,
            notificationIds: []
        )

        let updatedEvent = DayEvent(
            id: originalTask.id,
            title: title.isEmpty ? "New Task" : title,
            startHour: startHour,
            endHour: endHour,
            color: selectedColor,
            category: originalTask.category,
            emoji: selectedEmoji,
            description: notes,
            participants: originalTask.participants,
            isCompleted: originalTask.isCompleted,
            notificationSettings: notificationSettings
        )

        viewModel.updateEvent(originalTask, with: updatedEvent, for: selectedDate)

        
        if notificationEnabled && !notificationMinutes.isEmpty {
            Task {
                let identifiers = await NotificationService.shared.scheduleNotifications(
                    for: updatedEvent,
                    on: selectedDate,
                    minutesBeforeOptions: notificationMinutes
                )

                
                if !identifiers.isEmpty {
                    var finalSettings = notificationSettings
                    finalSettings.notificationIds = identifiers
                    var finalEvent = updatedEvent
                    finalEvent.notificationSettings = finalSettings
                    viewModel.updateEvent(updatedEvent, with: finalEvent, for: selectedDate)
                } else if !notificationMinutes.isEmpty {
                    
                    await MainActor.run {
                        showNotificationError("Failed to schedule notifications. The task time may be in the past or notifications are disabled.")
                    }
                }
            }
        }

        onUpdateComplete?()
        dismiss()
    }

    private func createTask() {
        let calendar = Calendar.current
        let startHour = Double(calendar.component(.hour, from: startTime)) +
                       Double(calendar.component(.minute, from: startTime)) / 60
        let endHourCalculated = Double(calendar.component(.hour, from: endTime)) +
                     Double(calendar.component(.minute, from: endTime)) / 60
        let endHour = endHourCalculated > startHour ? endHourCalculated : endHourCalculated + 24

        
        let notificationSettings = NotificationSettings(
            enabled: notificationEnabled,
            minutesBefore: notificationMinutes,
            notificationIds: []
        )

        let newEvent = DayEvent(
            title: title.isEmpty ? "New Task" : title,
            startHour: startHour,
            endHour: endHour,
            color: selectedColor,
            category: "Custom",
            emoji: selectedEmoji,
            description: notes,
            participants: [],
            isCompleted: false,
            notificationSettings: notificationSettings
        )

        viewModel.addEvent(newEvent, for: selectedDate, repeatDaily: repeatEnabled)

        
        if notificationEnabled && !notificationMinutes.isEmpty {
            Task {
                let identifiers = await NotificationService.shared.scheduleNotifications(
                    for: newEvent,
                    on: selectedDate,
                    minutesBeforeOptions: notificationMinutes
                )

                if !identifiers.isEmpty {
                    var updatedSettings = notificationSettings
                    updatedSettings.notificationIds = identifiers
                    var updatedEvent = newEvent
                    updatedEvent.notificationSettings = updatedSettings
                    viewModel.updateEvent(newEvent, with: updatedEvent, for: selectedDate)
                } else if !notificationMinutes.isEmpty {
                    
                    await MainActor.run {
                        showNotificationError("Failed to schedule notifications. The task time may be in the past or notifications are disabled.")
                    }
                }
            }
        }

        dismiss()
    }

    

    private func checkNotificationPermissionAndOpen() async {
        let status = await NotificationService.shared.checkAuthorizationStatus()

        switch status {
        case .authorized:
            
            await MainActor.run {
                showNotificationPicker = true
            }

        case .notDetermined:
            
            let granted = await NotificationService.shared.requestAuthorization()
            await MainActor.run {
                if granted {
                    showNotificationPicker = true
                } else {
                    showNotificationPermissionAlert = true
                }
            }

        case .denied, .provisional, .ephemeral:
            
            await MainActor.run {
                showNotificationPermissionAlert = true
            }

        @unknown default:
            await MainActor.run {
                showNotificationPermissionAlert = true
            }
        }
    }

    private func showNotificationError(_ message: String) {
        notificationErrorMessage = message
        showNotificationFailureAlert = true
    }
}

struct OptionRow: View {
    let icon: String
    let title: String
    let value: String
    let showChevron: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)

                Spacer()

                Text(value)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))

                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 20) {

                
                VStack(spacing: 12) {




                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .colorScheme(.dark)
                        .accentColor(Color.appPrimary)

                }

            }
        }
        .presentationBackground {
            Color.black.opacity(0.8)
        }
        .presentationCornerRadius(24)
    }
}

struct TimePickerSheet: View {
    @Binding var startTime: Date
    @Binding var endTime: Date
    @Environment(\.dismiss) var dismiss
    @State private var animateIn = false

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter
    }

    private var periodFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        return formatter
    }

    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.height < 600
            let horizontalPadding: CGFloat = min(geometry.size.width * 0.06, 24)
            let timeFontSize: CGFloat = isCompact ? 38 : min(geometry.size.width * 0.12, 48)
            let periodFontSize: CGFloat = isCompact ? 16 : 20

            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Set Time")
                                    .font(.system(size: isCompact ? 20 : 24, weight: .bold))
                                    .foregroundColor(.white)

                                Text("Choose start and end times")
                                    .font(.system(size: isCompact ? 11 : 13))
                                    .foregroundColor(.white.opacity(0.5))
                            }

                            Spacer()
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, isCompact ? 16 : 28)
                        .padding(.bottom, isCompact ? 12 : 20)

                        VStack(spacing: isCompact ? 12 : 20) {
                            
                            TimeCard(
                                label: "START",
                                icon: "sunrise.fill",
                                iconColor: Color.appPrimary,
                                time: startTime,
                                timeBinding: $startTime,
                                timeFormatter: timeFormatter,
                                periodFormatter: periodFormatter,
                                timeFontSize: timeFontSize,
                                periodFontSize: periodFontSize,
                                isCompact: isCompact,
                                gradientColors: [Color.appPrimary.opacity(0.3), Color.appPrimary.opacity(0.05)],
                                shadowColor: Color.appPrimary.opacity(0.1)
                            )

                            
                            if !isCompact {
                                HStack {
                                    Spacer()

                                    VStack(spacing: 4) {
                                        Circle()
                                            .fill(Color.appPrimary.opacity(0.3))
                                            .frame(width: 4, height: 4)

                                        Rectangle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.appPrimary.opacity(0.3), Color.appPrimary.opacity(0.1)],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .frame(width: 2, height: 20)

                                        Circle()
                                            .fill(Color.appPrimary.opacity(0.3))
                                            .frame(width: 4, height: 4)
                                    }

                                    Spacer()
                                }
                            }

                            
                            TimeCard(
                                label: "END",
                                icon: "sunset.fill",
                                iconColor: Color.orange,
                                time: endTime,
                                timeBinding: $endTime,
                                timeFormatter: timeFormatter,
                                periodFormatter: periodFormatter,
                                timeFontSize: timeFontSize,
                                periodFontSize: periodFontSize,
                                isCompact: isCompact,
                                gradientColors: [Color.orange.opacity(0.3), Color.orange.opacity(0.05)],
                                shadowColor: Color.orange.opacity(0.1)
                            )

                            
                            HStack(spacing: isCompact ? 8 : 10) {
                                ZStack {
                                    Circle()
                                        .fill(Color.appPrimary.opacity(0.15))
                                        .frame(width: isCompact ? 36 : 40, height: isCompact ? 36 : 40)

                                    Image(systemName: "timer")
                                        .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                                        .foregroundColor(Color.appPrimary)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Total Duration")
                                        .font(.system(size: isCompact ? 10 : 11, weight: .medium))
                                        .foregroundColor(.white.opacity(0.5))

                                    Text(durationString)
                                        .font(.system(size: isCompact ? 16 : 18, weight: .bold, design: .rounded))
                                        .foregroundColor(Color.appPrimary)
                                }

                                Spacer()

                                
                                HStack(spacing: 4) {
                                    ForEach(0..<max(0, min(Int(endTime.timeIntervalSince(startTime) / 1800), 8)), id: \.self) { _ in
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.appPrimary.opacity(0.6))
                                            .frame(width: 4, height: isCompact ? 12 : 16)
                                    }
                                }
                            }
                            .padding(isCompact ? 12 : 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.04))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, 8)
                        .padding(.bottom, 50)
                    }
                    .padding(.bottom, 30)
                }
                .scaleEffect(animateIn ? 1 : 0.95)
                .opacity(animateIn ? 1 : 0)
                .onAppear {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        animateIn = true
                    }
                }
            }
        }
        .presentationBackground {
            Color.black.opacity(0.85)
        }
        .presentationCornerRadius(28)
    }

    private var durationString: String {
        let duration = endTime.timeIntervalSince(startTime)

        
        if duration <= 0 {
            return "0 min"
        }

        let minutes = Int(duration / 60)
        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if hours > 0 && remainingMinutes > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else if hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        } else {
            return "\(minutes) min"
        }
    }
}


struct TimeCard: View {
    let label: String
    let icon: String
    let iconColor: Color
    let time: Date
    @Binding var timeBinding: Date
    let timeFormatter: DateFormatter
    let periodFormatter: DateFormatter
    let timeFontSize: CGFloat
    let periodFontSize: CGFloat
    let isCompact: Bool
    let gradientColors: [Color]
    let shadowColor: Color

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(label)
                    .font(.system(size: isCompact ? 10 : 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                    .tracking(1.2)

                Spacer()

                Image(systemName: icon)
                    .font(.system(size: isCompact ? 12 : 14))
                    .foregroundColor(iconColor.opacity(0.6))
            }
            .padding(.horizontal, isCompact ? 16 : 20)
            .padding(.top, isCompact ? 12 : 16)
            .padding(.bottom, isCompact ? 8 : 12)

            HStack(spacing: 12) {
                
                HStack(spacing: 4) {
                    Text(timeFormatter.string(from: time))
                        .font(.system(size: timeFontSize, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)

                    Text(periodFormatter.string(from: time))
                        .font(.system(size: periodFontSize, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .offset(y: timeFontSize * 0.16)
                }

                Spacer()

                
                DatePicker("", selection: $timeBinding, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .accentColor(iconColor)
                    .scaleEffect(isCompact ? 1.0 : 1.1)
            }
            .padding(.horizontal, isCompact ? 16 : 20)
            .padding(.bottom, isCompact ? 12 : 20)
        }
        .background(
            RoundedRectangle(cornerRadius: isCompact ? 16 : 20)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: isCompact ? 16 : 20)
                        .stroke(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: shadowColor, radius: isCompact ? 10 : 20, x: 0, y: isCompact ? 5 : 10)
    }
}

struct NotificationPickerSheet: View {
    @Binding var isEnabled: Bool
    @Binding var selectedMinutes: [Int]
    @Environment(\.dismiss) var dismiss

    private let notificationOptions: [(label: String, minutes: Int)] = [
        ("At time of event", 0),
        ("5 minutes before", 5),
        ("15 minutes before", 15),
        ("30 minutes before", 30),
        ("1 hour before", 60)
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notifications")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)

                        Text("Get reminded before your task")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)

                
                HStack {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.appPrimary.opacity(0.15))
                                .frame(width: 40, height: 40)

                            Image(systemName: "bell.badge")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.appPrimary)
                        }

                        Text("Enable Notifications")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Toggle("", isOn: $isEnabled)
                        .tint(Color.appPrimary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)

                if isEnabled {
                    VStack(spacing: 12) {
                        ForEach(notificationOptions, id: \.minutes) { option in
                            NotificationOptionRow(
                                label: option.label,
                                minutes: option.minutes,
                                isSelected: selectedMinutes.contains(option.minutes),
                                onTap: {
                                    if selectedMinutes.contains(option.minutes) {
                                        selectedMinutes.removeAll { $0 == option.minutes }
                                    } else {
                                        selectedMinutes.append(option.minutes)
                                        selectedMinutes.sort(by: >)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()
            }
        }
        .presentationBackground {
            Color.black.opacity(0.85)
        }
        .presentationCornerRadius(24)
    }
}

struct NotificationOptionRow: View {
    let label: String
    let minutes: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: minutes == 0 ? "clock" : "clock.badge.exclamationmark")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 24)

                    Text(label)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color.appPrimary)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 22))
                        .foregroundColor(.white.opacity(0.2))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.appPrimary.opacity(0.1) : Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.appPrimary.opacity(0.3) : Color.white.opacity(0.05),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CreateTaskSheet(viewModel: HomeViewModel())
}
