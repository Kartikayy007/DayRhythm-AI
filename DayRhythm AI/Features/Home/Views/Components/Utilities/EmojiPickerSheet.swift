//
//  EmojiPickerSheet.swift
//  DayRhythm AI
//
//  Created by kartikay on 24/10/25.
//

import SwiftUI

struct EmojiPickerSheet: View {
    @Binding var selectedEmoji: String
    @Environment(\.dismiss) var dismiss

    let allEmojis = ["📅", "👥", "💼", "🎯", "📊", "✏️", "🎨", "💻", "📱", "🏃", "🍔", "☕️", "🏠", "🎮", "📚", "🎵", "⚡", "🔥", "💡", "🎯", "🚀", "⭐", "🌟", "💎", "🎁", "🎉", "🎊", "✨", "💯", "🔔"]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Text("Choose Emoji")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                // Emoji Grid
                ScrollView(.vertical, showsIndicators: false) {
                    let columns = [GridItem(.adaptive(minimum: 60), spacing: 16)]
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(allEmojis, id: \.self) { emoji in
                            Button(action: {
                                selectedEmoji = emoji
                                dismiss()
                            }) {
                                Text(emoji)
                                    .font(.system(size: 40))
                                    .frame(height: 70)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(selectedEmoji == emoji ? Color.white.opacity(0.2) : Color.white.opacity(0.08))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white, lineWidth: selectedEmoji == emoji ? 2 : 0)
                                    )
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
    }
}

#Preview {
    EmojiPickerSheet(selectedEmoji: .constant("📅"))
}
