//
//  AIInsightView.swift
//  DayRhythm AI
//
//  Created by Claude Code on 29/10/25.
//

import SwiftUI

struct AIInsightView: View {
    let insight: String
    let isLoading: Bool

    @State private var displayedText: String = ""
    @State private var currentIndex: Int = 0
    @State private var typingTimer: Timer? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))

                Text("AI Insight")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))

                Spacer()

                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white.opacity(0.6))
                }
            }

            
            if isLoading {
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<3) { index in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 14)
                            .frame(maxWidth: index == 2 ? 200 : .infinity)
                            .opacity(0.6)
                            .animation(
                                .easeInOut(duration: 1.0)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                                value: isLoading
                            )
                    }
                }
            } else if !insight.isEmpty {
                
                Text(displayedText.isEmpty ? insight : displayedText)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .onChange(of: isLoading) { newLoadingState in
            
            if !newLoadingState && !insight.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    startTypingAnimation(text: insight)
                }
            }
        }
        .onChange(of: insight) { newInsight in
            
            if !newInsight.isEmpty && !isLoading {
                typingTimer?.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    startTypingAnimation(text: newInsight)
                }
            }
        }
        .onAppear {
            if !insight.isEmpty && !isLoading {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    startTypingAnimation(text: insight)
                }
            }
        }
        .onDisappear {
            typingTimer?.invalidate()
        }
    }

    private func startTypingAnimation(text: String) {
        
        displayedText = ""
        currentIndex = 0
        typingTimer?.invalidate()

        
        guard !text.isEmpty else { return }

        let characters = Array(text)

        
        typingTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            DispatchQueue.main.async {
                if currentIndex < characters.count {
                    displayedText.append(characters[currentIndex])
                    currentIndex += 1
                } else {
                    timer.invalidate()
                    typingTimer = nil
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 20) {
            
            AIInsightView(
                insight: "",
                isLoading: true
            )
            .padding(.horizontal, 20)

            
            AIInsightView(
                insight: "Morning tasks like this benefit from fresh mental energy. 4h58m is a solid duration - consider tackling the hardest parts first while your focus is strongest.",
                isLoading: false
            )
            .padding(.horizontal, 20)
        }
    }
}
