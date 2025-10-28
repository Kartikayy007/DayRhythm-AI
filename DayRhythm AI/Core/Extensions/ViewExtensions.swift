//
//  ViewExtensions.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI

// MARK: - Keyboard Management

/// A ViewModifier that handles keyboard dismissal
struct KeyboardDismissModifier: ViewModifier {
    var mode: KeyboardDismissMode = .onTap

    func body(content: Content) -> some View {
        switch mode {
        case .onTap:
            content
                .onTapGesture {
                    hideKeyboard()
                }
        case .onDrag:
            content
                .simultaneousGesture(
                    DragGesture().onChanged { _ in
                        hideKeyboard()
                    }
                )
        case .onTapAndDrag:
            content
                .onTapGesture {
                    hideKeyboard()
                }
                .simultaneousGesture(
                    DragGesture().onChanged { _ in
                        hideKeyboard()
                    }
                )
        case .interactive:
            content
                .scrollDismissesKeyboard(.interactively)
        case .immediately:
            content
                .scrollDismissesKeyboard(.immediately)
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

enum KeyboardDismissMode {
    case onTap
    case onDrag
    case onTapAndDrag
    case interactive  // For ScrollView: dismiss as you scroll
    case immediately  // For ScrollView: dismiss immediately on scroll
}

extension View {
    /// Dismisses keyboard when tapping outside of text fields
    /// - Parameter mode: The mode for dismissing keyboard (default: .onTap)
    /// - Usage: `.hideKeyboardOnTap()` or `.hideKeyboardOnTap(.onTapAndDrag)`
    func hideKeyboardOnTap(_ mode: KeyboardDismissMode = .onTap) -> some View {
        modifier(KeyboardDismissModifier(mode: mode))
    }

    /// Dismisses keyboard programmatically
    /// - Usage: Call `View.hideKeyboard()` from any view
    static func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }

    /// Dismisses keyboard when scrolling (for ScrollView)
    /// - Usage: Add to ScrollView: `.keyboardDismissMode(.interactive)`
    func keyboardDismissMode(_ mode: KeyboardDismissMode) -> some View {
        modifier(KeyboardDismissModifier(mode: mode))
    }
}

// MARK: - Corner Radius

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
