//
//  ContentView.swift
//  DayRhythm AI
//
//  Created by kartikay on 18/10/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        MainTabView()
            .fontDesign(.rounded)
            .hideKeyboardOnTap()
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState.shared)
}
