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

        var alerts: [String] = []

        if notificationMinutes.contains(0) {
            alerts.append("Start")
        }
        if notificationMinutes.contains(-1) {
            alerts.append("End")
        }

        for mins in notificationMinutes {
            if mins > 0 {
                alerts.append("\(mins)min before")
            }
        }

        if alerts.isEmpty {
            return "No Alerts"
        } else if alerts.count == 1 {
            return alerts[0]
        } else {
            return "\(alerts.count) alerts"
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
            Color(white: 0.05)
        }
        .presentationCornerRadius(24)
    }
}

struct TimePickerSheet: View {
    @Binding var startTime: Date
    @Binding var endTime: Date
    @Environment(\.dismiss) var dismiss
    @State private var animateIn = false
    @State private var showingStartPicker = false
    @State private var showingEndPicker = false

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
            let timeFontSize: CGFloat = isCompact ? 42 : min(geometry.size.width * 0.13, 52)
            let periodFontSize: CGFloat = isCompact ? 18 : 22

            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Set Time")
                                .font(.system(size: isCompact ? 22 : 26, weight: .bold))
                                .foregroundColor(.white)

                            Text("Tap time to edit")
                                .font(.system(size: isCompact ? 12 : 14))
                                .foregroundColor(.white.opacity(0.5))
                        }

                        Spacer()
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, isCompact ? 20 : 32)
                    .padding(.bottom, isCompact ? 16 : 24)

                    VStack(spacing: isCompact ? 20 : 32) {

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
                            isShowingPicker: $showingStartPicker,
                            gradientColors: [Color.appPrimary.opacity(0.3), Color.appPrimary.opacity(0.05)],
                            shadowColor: Color.appPrimary.opacity(0.15)
                        )


                        if !isCompact {
                            HStack {
                                Spacer()

                                VStack(spacing: 6) {
                                    Circle()
                                        .fill(Color.appPrimary.opacity(0.4))
                                        .frame(width: 5, height: 5)

                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.appPrimary.opacity(0.4), Color.appPrimary.opacity(0.1)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(width: 2, height: 30)

                                    Circle()
                                        .fill(Color.orange.opacity(0.4))
                                        .frame(width: 5, height: 5)
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
                            isShowingPicker: $showingEndPicker,
                            gradientColors: [Color.orange.opacity(0.3), Color.orange.opacity(0.05)],
                            shadowColor: Color.orange.opacity(0.15)
                        )
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 40)

                    Spacer()
                }
                .scaleEffect(animateIn ? 1 : 0.95)
                .opacity(animateIn ? 1 : 0)
                .onAppear {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        animateIn = true
                    }
                }

                
                if showingStartPicker {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                showingStartPicker = false
                            }
                        }
                        .overlay(
                            VStack(spacing: 16) {
                                Text("SELECT START TIME")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white.opacity(0.5))
                                    .tracking(1.2)

                                DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .colorScheme(.dark)
                                    .accentColor(Color.appPrimary)
                                    .frame(height: 200)
                                    .padding(.horizontal, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(white: 0.08))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.appPrimary.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.6), radius: 30, y: 10)
                                    .onChange(of: startTime) {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            withAnimation(.spring(response: 0.3)) {
                                                showingStartPicker = false
                                            }
                                        }
                                    }
                            }
                            .padding(.horizontal, 40)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        )
                        .transition(.opacity)
                        .zIndex(1000)
                }

                
                if showingEndPicker {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                showingEndPicker = false
                            }
                        }
                        .overlay(
                            VStack(spacing: 16) {
                                Text("SELECT END TIME")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white.opacity(0.5))
                                    .tracking(1.2)

                                DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .colorScheme(.dark)
                                    .accentColor(Color.orange)
                                    .frame(height: 200)
                                    .padding(.horizontal, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(white: 0.08))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.6), radius: 30, y: 10)
                                    .onChange(of: endTime) {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            withAnimation(.spring(response: 0.3)) {
                                                showingEndPicker = false
                                            }
                                        }
                                    }
                            }
                            .padding(.horizontal, 40)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        )
                        .transition(.opacity)
                        .zIndex(1000)
                }
            }
        }
        .presentationBackground {
            Color(white: 0.05)
        }
        .presentationCornerRadius(28)
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
    @Binding var isShowingPicker: Bool
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

            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    isShowingPicker.toggle()
                }
            }) {
                HStack(spacing: 4) {
                    Text(timeFormatter.string(from: time))
                        .font(.system(size: timeFontSize, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)

                    Text(periodFormatter.string(from: time))
                        .font(.system(size: periodFontSize, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .offset(y: timeFontSize * 0.16)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, isCompact ? 16 : 20)
            .padding(.bottom, isCompact ? 16 : 20)
        }
        .background(
            RoundedRectangle(cornerRadius: isCompact ? 16 : 20)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: isCompact ? 16 : 20)
                        .stroke(
                            LinearGradient(
                                colors: [iconColor.opacity(0.2), iconColor.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isShowingPicker ? 2 : 1
                        )
                )
        )
        .shadow(color: shadowColor, radius: isCompact ? 10 : 20, x: 0, y: isCompact ? 5 : 10)
        .scaleEffect(isShowingPicker ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isShowingPicker)
    }
}

struct NotificationPickerSheet: View {
    @Binding var isEnabled: Bool
    @Binding var selectedMinutes: [Int]
    @Environment(\.dismiss) var dismiss
    @State private var animateIn = false
    @State private var atStartEnabled = false
    @State private var atEndEnabled = false
    @State private var customEnabled = false
    @State private var customMinutes = 5

    private let customTimeOptions = [5, 10, 15, 30, 45, 60]

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)

            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 40, height: 4)
                        .padding(.top, 12)

                    HStack {
                        Text("Alerts")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Spacer()

                        Button(action: {
                            updateSelectedMinutes()
                            dismiss()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 32, height: 32)

                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }

                
                VStack(spacing: 20) {
                    
                    AlertRow(
                        icon: "play.circle",
                        iconColor: Color.green,
                        label: "At start of task",
                        isSelected: $atStartEnabled
                    )

                    Divider()
                        .background(Color.white.opacity(0.06))
                        .padding(.horizontal, 24)

                    
                    AlertRow(
                        icon: "stop.circle",
                        iconColor: Color.orange,
                        label: "At end of task",
                        isSelected: $atEndEnabled
                    )

                    Divider()
                        .background(Color.white.opacity(0.06))
                        .padding(.horizontal, 24)

                    
                    VStack(spacing: 12) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        customEnabled
                                        ? Color.appPrimary.opacity(0.15)
                                        : Color.white.opacity(0.05)
                                    )
                                    .frame(width: 44, height: 44)

                                Image(systemName: "clock.badge")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(
                                        customEnabled
                                        ? Color.appPrimary
                                        : .white.opacity(0.5)
                                    )
                            }

                            Text("\(customMinutes) minutes before")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.white)

                            Spacer()

                            Toggle("", isOn: $customEnabled.animation(.spring(response: 0.3)))
                                .tint(Color.appPrimary)
                                .scaleEffect(0.95)
                        }
                        .padding(.horizontal, 24)

                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(customTimeOptions, id: \.self) { minutes in
                                    Button(action: {
                                        customMinutes = minutes
                                        if !customEnabled {
                                            customEnabled = true
                                        }
                                    }) {
                                        Text("\(minutes) min")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(
                                                customMinutes == minutes && customEnabled
                                                ? .white
                                                : .white.opacity(0.6)
                                            )
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(
                                                        customMinutes == minutes && customEnabled
                                                        ? Color.appPrimary
                                                        : Color.white.opacity(0.08)
                                                    )
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .opacity(customEnabled ? 1 : 0.6)
                    }
                }
                .padding(.top, 20)

                Spacer()
            }
            .scaleEffect(animateIn ? 1 : 0.9)
            .opacity(animateIn ? 1 : 0)
        }
        .onAppear {
            loadCurrentSettings()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                animateIn = true
            }
        }
        .onDisappear {
            updateSelectedMinutes()
        }
        .presentationBackground {
            Color.black.opacity(0.9)
                .background(.ultraThinMaterial)
        }
        .presentationCornerRadius(32)
    }

    private func loadCurrentSettings() {
        
        atStartEnabled = selectedMinutes.contains(0)
        atEndEnabled = selectedMinutes.contains(-1) 

        
        for minutes in selectedMinutes {
            if minutes > 0 {
                customEnabled = true
                customMinutes = minutes
                break
            }
        }

        
        isEnabled = !selectedMinutes.isEmpty
    }

    private func updateSelectedMinutes() {
        selectedMinutes.removeAll()

        if atStartEnabled {
            selectedMinutes.append(0)
        }

        if atEndEnabled {
            selectedMinutes.append(-1) 
        }

        if customEnabled {
            selectedMinutes.append(customMinutes)
        }

        isEnabled = !selectedMinutes.isEmpty
    }
}

struct AlertRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    @Binding var isSelected: Bool

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        isSelected
                        ? iconColor.opacity(0.15)
                        : Color.white.opacity(0.05)
                    )
                    .frame(width: 44, height: 44)
                    .animation(.spring(response: 0.3), value: isSelected)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(
                        isSelected
                        ? iconColor
                        : .white.opacity(0.5)
                    )
                    .animation(.spring(response: 0.3), value: isSelected)
            }

            Text(label)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.white)

            Spacer()

            Toggle("", isOn: $isSelected.animation(.spring(response: 0.3)))
                .tint(iconColor)
                .scaleEffect(0.95)
        }
        .padding(.horizontal, 24)
        .contentShape(Rectangle())
    }
}


#Preview {
    CreateTaskSheet(viewModel: HomeViewModel())
}
