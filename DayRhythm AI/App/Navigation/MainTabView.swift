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
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.82, green: 0.49, blue: 0.42))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
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
