//
//  CreateTaskPreviewCard.swift
//  DayRhythm AI
//
//  Preview card component for CreateTaskSheet
//

import SwiftUI

struct CreateTaskPreviewCard: View {
    @Binding var title: String
    let emoji: String
    let color: Color
    let startTime: Date
    let endTime: Date
    var isTitleFocused: FocusState<Bool>.Binding

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let start = formatter.string(from: startTime)
        let end = formatter.string(from: endTime)

        let duration = endTime.timeIntervalSince(startTime)
        let minutes = Int(duration / 60)
        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        let durationString: String
        if hours > 0 && remainingMinutes > 0 {
            durationString = "\(hours)h \(remainingMinutes)min"
        } else if hours > 0 {
            durationString = "\(hours) hr"
        } else {
            durationString = "\(minutes) min"
        }

        return "\(start) - \(end) (\(durationString))"
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 70)

                Text(emoji)
                    .font(.system(size: 32))
                    .frame(width: 60, height: 65)

                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Color.gray))
                    .offset(x: 5, y: 5)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(timeString)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))

                ZStack(alignment: .bottomLeading) {
                    TextField("New Task", text: $title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .focused(isTitleFocused)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onTapGesture {
                            isTitleFocused.wrappedValue = true
                        }

                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 1)
                        .offset(y: 4)
                }
            }

            Spacer()

        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(color)
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var title = "Answer Emails"
        @FocusState private var isFocused: Bool

        var body: some View {
            CreateTaskPreviewCard(
                title: $title,
                emoji: "🤞",
                color: Color(red: 0, green: 0, blue: 0),
                startTime: Date(),
                endTime: Date().addingTimeInterval(3600),
                isTitleFocused: $isFocused
            )
            .padding()
            .background(Color.black)
        }
    }

    return PreviewWrapper()
}
