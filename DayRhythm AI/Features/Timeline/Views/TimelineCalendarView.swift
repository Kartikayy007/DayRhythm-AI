//
//  TimelineCalendarView.swift
//  DayRhythm AI
//
//  Created by kartikay on 29/10/25.
//

import SwiftUI

struct TimelineCalendarView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    var onEventTap: ((DayEvent) -> Void)?

    @State private var currentTime = Date()

    private var currentTimeInHours: Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentTime)
        let minute = calendar.component(.minute, from: currentTime)
        let time = Double(hour) + (Double(minute) / 60.0)
        return time == 0 ? 24 : time
    }

    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                HStack(spacing: 4) {
                    Text("☀️")
                        .font(.system(size: 14))
                    Text("6 AM")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.leading, 16)

                Spacer()
            }
            .padding(.vertical, 12)

            
            ForEach(homeViewModel.events.sorted { $0.startHour < $1.startHour }) { event in
                TimelineTaskRow(
                    event: event,
                    currentTimeInHours: currentTimeInHours,
                    showTickMark: false
                )
                .onTapGesture {
                    onEventTap?(event)
                }
            }

            
            HStack {
                HStack(spacing: 4) {
                    Text("🌙")
                        .font(.system(size: 14))
                    Text("12 AM")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.leading, 16)

                Spacer()
            }
            .padding(.vertical, 12)
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                currentTime = Date()
            }
        }
    }

}


private struct TimelineTaskRow: View {
    let event: DayEvent
    let currentTimeInHours: Double
    let showTickMark: Bool

    private var isPastEvent: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let eventDate = formatter.date(from: event.dateString) else {
            
            return event.endHour < currentTimeInHours
        }

        let eventDay = calendar.startOfDay(for: eventDate)

        
        if eventDay < today {
            return true
        }

        
        if eventDay == today && event.endHour < currentTimeInHours {
            return true
        }

        
        return false
    }

    private func timeString(for time: Double) -> String {
        let hour = Int(time)
        let minute = Int((time - Double(hour)) * 60)

        var hourDisplay: Int
        var period: String

        if hour == 24 || hour == 0 {
            hourDisplay = 12
            period = "AM"
        } else if hour < 12 {
            hourDisplay = hour
            period = "AM"
        } else if hour == 12 {
            hourDisplay = 12
            period = "PM"
        } else {
            hourDisplay = hour - 12
            period = "PM"
        }

        if minute == 0 {
            return "\(hourDisplay) \(period)"
        } else {
            return String(format: "%d:%02d %@", hourDisplay, minute, period)
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            
            HStack(spacing: 0) {
                Text(timeString(for: event.startHour))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.leading, 16)

                Spacer()
            }

            
            ZStack {
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(event.color.opacity(isPastEvent ? 0.1 : 0.7))

                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        
                        HStack(spacing: 8) {
                            Text(event.emoji)
                                .font(.system(size: 18))

                            Text(event.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(isPastEvent ? 0.7 : 1.0))
                                .strikethrough(isPastEvent, color: .white.opacity(0.9))
                                .lineLimit(1)
                        }

                        
                        Text(event.durationString)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(isPastEvent ? 0.3 : 0.6))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .frame(height: 70)
            .padding(.horizontal, 16)

            
            HStack(spacing: 0) {
                Text(timeString(for: event.endHour))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.leading, 16)

                Spacer()
            }
        }
    }
}

#Preview {
    @Previewable @StateObject var viewModel = {
        let vm = HomeViewModel()

        let sampleEvents = [
            DayEvent(
                title: "Morning Standup",
                startHour: 9,
                endHour: 9.5,
                color: .blue,
                category: "Work",
                emoji: "👥",
                description: "Daily team sync",
                participants: ["John", "Sarah"],
                isCompleted: false
            ),
            DayEvent(
                title: "Deep Work Session",
                startHour: 10,
                endHour: 12,
                color: .purple,
                category: "Work",
                emoji: "💻",
                description: "Focus time for coding",
                participants: [],
                isCompleted: false
            ),
            DayEvent(
                title: "Lunch Break",
                startHour: 12.5,
                endHour: 13.5,
                color: .orange,
                category: "Personal",
                emoji: "🍽️",
                description: "Lunch with team",
                participants: [],
                isCompleted: false
            ),
            DayEvent(
                title: "Client Meeting",
                startHour: 15,
                endHour: 16,
                color: .green,
                category: "Work",
                emoji: "📞",
                description: "Quarterly review",
                participants: ["Client A"],
                isCompleted: false
            ),
            DayEvent(
                title: "Gym Workout",
                startHour: 18,
                endHour: 19.5,
                color: .red,
                category: "Health",
                emoji: "🏋️",
                description: "Strength training",
                participants: [],
                isCompleted: false
            )
        ]

        for event in sampleEvents {
            vm.addEvent(event)
        }

        return vm
    }()

    ZStack {
        Color.black.ignoresSafeArea()
        TimelineCalendarView(homeViewModel: viewModel)
    }
}
