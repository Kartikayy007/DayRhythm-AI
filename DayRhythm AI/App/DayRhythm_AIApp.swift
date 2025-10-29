//
//  DayRhythm_AIApp.swift
//  DayRhythm AI
//
//  Created by kartikay on 18/10/25.
//

import SwiftUI

@main
struct DayRhythm_AIApp: App {
    @StateObject private var appState = AppState.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
