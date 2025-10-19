//
//  MainTabView.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI

struct MainTabView: View {
    
    var body: some View {
        TabView() {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            Text("Add Tab")
                .tabItem {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            
            Text("Calendar Tab")
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
        }
    }
}

#Preview {
    MainTabView()
}
