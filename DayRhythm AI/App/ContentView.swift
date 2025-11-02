//
//  ContentView.swift
//  DayRhythm AI
//
//  Created by kartikay on 18/10/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            } else {
                MainTabView()
                    .fontDesign(.rounded)
                    .hideKeyboardOnTap()
                    .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {  
    ContentView()
        .environmentObject(AppState.shared)
}
