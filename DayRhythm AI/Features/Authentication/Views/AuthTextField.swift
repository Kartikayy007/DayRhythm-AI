//
//  AuthTextField.swift
//  DayRhythm AI
//
//  Created by kartikay on 29/10/25.
//

import SwiftUI

struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 24)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .textContentType(.password)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .keyboardType(placeholder.lowercased().contains("email") ? .emailAddress : .default)
                    .textContentType(placeholder.lowercased().contains("email") ? .emailAddress : .none)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 16) {
            AuthTextField(
                icon: "envelope",
                placeholder: "Email",
                text: .constant("")
            )

            AuthTextField(
                icon: "lock",
                placeholder: "Password",
                text: .constant(""),
                isSecure: true
            )
        }
        .padding()
    }
}
