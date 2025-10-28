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

    @State private var title = ""
    @State private var selectedEmoji = "🤞"
    @State private var selectedColor = Color(red: 0, green: 0, blue: 0)
    @State private var selectedDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(900)
    
    @State private var alertCount = 3
    @State private var repeatEnabled = false
    @State private var notes = ""

    @State private var showColorEmojiPicker = false
    @State private var showDatePicker = false
    @State private var showTimePicker = false

    @FocusState private var isNotesFieldFocused: Bool
    @FocusState private var isTitleFieldFocused: Bool

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
                                title: "\(alertCount) Alerts",
                                value: "Nudge",
                                showChevron: true,
                                action: {
                                    // later stuff
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
            Button(action: createTask) {
                Text("Add to schedule")
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
                .presentationDetents([.height(332)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showTimePicker) {
            TimePickerSheet(
                startTime: $startTime,
                endTime: $endTime
            )
            .presentationDetents([.height(400)])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTitleFieldFocused = true
            }
        }
    }

    private func createTask() {
        let calendar = Calendar.current
        let startHour = Double(calendar.component(.hour, from: startTime)) +
                       Double(calendar.component(.minute, from: startTime)) / 60
        let endHourCalculated = Double(calendar.component(.hour, from: endTime)) +
                     Double(calendar.component(.minute, from: endTime)) / 60
        let endHour = endHourCalculated > startHour ? endHourCalculated : endHourCalculated + 24

        let newEvent = DayEvent(
            title: title.isEmpty ? "New Task" : title,
            startHour: startHour,
            endHour: endHour,
            color: selectedColor,
            category: "Custom",
            emoji: selectedEmoji,
            description: notes,
            participants: [],
            isCompleted: false
        )

        viewModel.addEvent(newEvent, repeatDaily: repeatEnabled)
        dismiss()
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
                // Header
                HStack {
                    Text("Select Date")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color.appPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .glassEffect(in: Capsule())
                }
                .padding(.horizontal)
                .padding(.top)

                // Date Picker with glass effect
                VStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 24))
                        .foregroundColor(Color.appPrimary)

                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .colorScheme(.dark)
                        .accentColor(Color.appPrimary)
                        .padding()
                        .glassEffect(in: .rect(cornerRadius: 20))
                }
                .padding(.horizontal)

                Spacer()
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

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Select Time")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color.appPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .glassEffect(in: Capsule())
                }
                .padding(.horizontal)
                .padding(.top)

                VStack(spacing: 16) {
                    // Start Time Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("START TIME")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 4)

                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(Color.appPrimary)
                                .font(.system(size: 18))

                            DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .colorScheme(.dark)
                                .accentColor(Color.appPrimary)

                            Spacer()

                            Text(timeFormatter.string(from: startTime))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .glassEffect(in: .rect(cornerRadius: 12))
                    }

                    // End Time Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("END TIME")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 4)

                        HStack {
                            Image(systemName: "clock.badge.checkmark.fill")
                                .foregroundColor(Color.appPrimary)
                                .font(.system(size: 18))

                            DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .colorScheme(.dark)
                                .accentColor(Color.appPrimary)

                            Spacer()

                            Text(timeFormatter.string(from: endTime))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .glassEffect(in: .rect(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)

                // Duration Display
                HStack(spacing: 12) {
                    Image(systemName: "timer")
                        .font(.system(size: 16))
                        .foregroundColor(Color.appPrimary)

                    Text("Duration")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))

                    Text(durationString)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.appPrimary)

                    Spacer()
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer()
            }
        }
        .presentationBackground {
            Color.black.opacity(0.8)
        }
        .presentationCornerRadius(24)
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
}

#Preview {
    CreateTaskSheet(viewModel: HomeViewModel())
}
