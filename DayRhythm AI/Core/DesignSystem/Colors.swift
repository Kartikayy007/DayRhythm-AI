//
//  Colors.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard hex.count == 6 else { return nil }

        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0

        guard scanner.scanHexInt64(&rgb) else { return nil }

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

extension Color {
    static let appPrimary = Color(hex: "d95639") ?? Color(red: 0.85, green: 0.34, blue: 0.22)
    static let appAccent = Color(red: 0.82, green: 0.49, blue: 0.42)
}

