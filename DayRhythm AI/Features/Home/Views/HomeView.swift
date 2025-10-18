//
//  HomeView.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                TopHeader(homeViewModel: viewModel)
                
                CircularDayDial(
                    events: viewModel.events,
                    selectedDate: viewModel.selectedDate
                )
                .padding(.top, 30)
                
                Spacer()
            }
        }
    }
}

#Preview {
    HomeView()
}
