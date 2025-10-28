//
//  ColorEmojiPickerSheet.swift
//  DayRhythm AI
//
//  Color and emoji picker modal for task creation
//

import SwiftUI

struct ColorEmojiPickerSheet: View {
    @Binding var selectedEmoji: String
    @Binding var selectedColor: Color
    @Environment(\.dismiss) var dismiss

    let colors: [Color] = [
        Color.appPrimary,
        Color(red: 0.95, green: 0.55, blue: 0.35),
        Color(red: 0.95, green: 0.85, blue: 0.35),
        Color(red: 0.35, green: 0.85, blue: 0.35),
        Color(red: 0.35, green: 0.65, blue: 0.95),
        Color(red: 0.35, green: 0.85, blue: 0.75),
        Color(red: 0.95, green: 0.35, blue: 0.35),
    ]

    let allEmojis = [
        "😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣",
        "📅", "👥", "💼", "🎯", "📊", "✏️", "🎨", "💻",
        "📱", "🏃", "🍔", "☕️", "🏠", "🎮", "📚", "🎵",
        "🎸", "🎹", "🎺", "🎻", "🎪", "🎭", "🎬", "🎯",
        "🎱", "🎳", "🎮", "🎰", "🎲", "🎷", "🎸", "🎹",
        "🏀", "🏈", "⚽️", "🎾", "🏐", "🏉", "🎱", "🏓",
        "🚗", "🚕", "🚙", "🚌", "🚎", "🏎", "🚓", "🚑", 
        "✈️", "🚀", "🛸", "🚁", "🛶", "⛵️", "🚤", "🛳",
        "🌍", "🌎", "🌏", "🌐", "🗺", "🏔", "⛰", "🌋",
        "🍎", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐",
        "🍔", "🍕", "🌭", "🥪", "🌮", "🌯", "🫔", "🥗",
        "☕️", "🍵", "🧃", "🥤", "🧋", "🍷", "🍸", "🍹",
        "@", "✉️", "📧", "💌", "📮", "📬", "📭", "📪"
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Color & Icon")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()

                    Spacer()

                }
                .padding()

                ScrollView {
                    GlassEffectContainer(spacing: 20) {
                        VStack(alignment: .leading, spacing: 24) {
                            HStack(spacing: 12) {
                                ForEach(colors, id: \.self) { color in
                                    Button(action: {
                                        selectedColor = color
                                    }) {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white.opacity(selectedColor == color ? 0.8 : 0.2), lineWidth: selectedColor == color ? 3 : 1)
                                                    .padding(2)
                                            )
                                            .shadow(color: color.opacity(selectedColor == color ? 0.4 : 0), radius: 8, x: 0, y: 2)
                                    }
                                }
                            }
                            .padding(12)
//                            .glassEffect(in: .rect(cornerRadius: 16))
                            .padding(.horizontal)

                            VStack(alignment: .leading, spacing: 12) {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                                    ForEach(allEmojis, id: \.self) { emoji in
                                        EmojiButton(emoji: emoji, isSelected: selectedEmoji == emoji) {
                                            selectedEmoji = emoji
                                        }
                                    }
                                }
                                .padding()
                            }
//                            .glassEffect(in: .rect(cornerRadius: 20))
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .presentationCornerRadius(28)
        .glassEffect(in: .rect(cornerRadius: 0))
    }
}

struct EmojiButton: View {
    let emoji: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                // Only show background for selected items
                if isSelected {
                    Circle()
                        .fill(Color.appPrimary.opacity(0.3))
                        .frame(width: 44, height: 44)
                }

                if emoji == "@" {
                    Text(emoji)
                        .font(.system(size: 28, weight: .regular))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                } else {
                    Text(emoji)
                        .font(.system(size: 28))
                }
            }
            .frame(width: 50, height: 50)
        }
    }
}

#Preview {
    ColorEmojiPickerSheet(
        selectedEmoji: .constant("@"),
        selectedColor: .constant(Color.red)
    )
}
