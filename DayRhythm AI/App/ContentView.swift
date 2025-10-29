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
        Group {
            if appState.isAuthenticated {
                
                MainTabView()
                    .fontDesign(.rounded)
                    .hideKeyboardOnTap()
            } else {
                
                AuthenticationGateView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState.shared)
}
 
