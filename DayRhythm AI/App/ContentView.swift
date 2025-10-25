//
//  ContentView.swift
//  DayRhythm AI
//
//  Created by kartikay on 18/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedDate = Date()
    
    var body: some View {
        MainTabView()
            .fontDesign(.rounded)
    }
}

#Preview {
    ContentView()
}
 
