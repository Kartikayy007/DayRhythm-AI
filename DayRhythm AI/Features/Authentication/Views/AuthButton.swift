//
//  AuthButton.swift
//  DayRhythm AI
//
//  Created by kartikay on 29/10/25.
//

import SwiftUI

enum AuthButtonStyle {
    case primary
    case apple
}

struct AuthButton: View {
    let title: String
    let icon: String?
    let style: AuthButtonStyle
    let isLoading: Bool
    let action: () -> Void

    init(
        title: String,
        icon: String? = nil,
        style: AuthButtonStyle = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: {
            if !isLoading {
                action()
            }
        }) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                    }

                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1.0)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return Color.appPrimary
        case .apple:
            return Color.white
        }
    }

    private var textColor: Color {
        switch style {
        case .primary:
            return .white
        case .apple:
            return .black
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary:
            return Color.clear
        case .apple:
            return Color.clear
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 20) {
            AuthButton(
                title: "Login",
                style: .primary,
                isLoading: false,
                action: {}
            )

            AuthButton(
                title: "Continue with Apple",
                icon: "apple.logo",
                style: .apple,
                isLoading: false,
                action: {}
            )

            AuthButton(
                title: "Loading...",
                style: .primary,
                isLoading: true,
                action: {}
            )
        }
        .padding()
    }
}
