//
//  MainTabView.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var showCreateTask = false
    @State private var selectedTab = 0
    @State private var previousTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            InboxView(homeViewModel: homeViewModel)
                .tabItem {
                    Label("Tasks", systemImage: "tray.fill")
                }
                .tag(0)

            HomeView(viewModel: homeViewModel)
                .tabItem {
                    Label("Timeline", systemImage: "clock.fill")
                }
                .tag(1)

            AIScheduleView(homeViewModel: homeViewModel)
                .tabItem {
                    Label("AI", systemImage: "sparkles")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)

            Color.clear
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }
                .tag(4)
        }
        .tint(Color(red: 0.95, green: 0.55, blue: 0.55))
        .onChange(of: selectedTab) { newValue in
            if newValue == 4 {
                showCreateTask = true
                selectedTab = previousTab
            } else {
                previousTab = newValue
            }
        }
        .sheet(isPresented: $showCreateTask) {
            CreateTaskSheet(viewModel: homeViewModel)
        }
    }
}


#Preview {
    MainTabView()
}
