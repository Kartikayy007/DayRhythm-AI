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

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                HomeView(viewModel: homeViewModel)
                    .tabItem {
                        Label("Inbox", systemImage: "tray.fill")
                    }

                HomeView(viewModel: homeViewModel)
                    .tabItem {
                        Label("Timeline", systemImage: "list.bullet")
                    }

                AIScheduleView(homeViewModel: homeViewModel)
                    .tabItem {
                        Label("AI", systemImage: "sparkles")
                    }

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
            .tint(Color(red: 0.95, green: 0.55, blue: 0.55))

            // Plus Button beside tab bar
            HStack {
                Spacer()

                Button(action: {
                    showCreateTask = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(Color(red: 0.95, green: 0.55, blue: 0.55))
                        )
                }
                .buttonStyle(.glass)
                .clipShape(Circle())
                .shadow(color: Color(red: 0.95, green: 0.55, blue: 0.55).opacity(0.4), radius: 10, x: 0, y: 5)
                .padding(.trailing, 20)
                .padding(.bottom, 10)
            }
        }
        .sheet(isPresented: $showCreateTask) {
            CreateTaskSheet(viewModel: homeViewModel)
        }
    }
}

// Placeholder Settings View
struct SettingsView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            Text("Settings")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    MainTabView()
}
