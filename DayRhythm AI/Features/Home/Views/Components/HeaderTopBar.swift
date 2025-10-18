//
//  HeaderTopBar.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI


struct HeaderTopBar: View {
    let currentMonth: String
    let onMonthPickerTap: () -> Void
    let onProfileTap: () -> Void
    
    var body: some View {
        HStack {
            Text(currentMonth)
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(.white)
            
            Button(action: onMonthPickerTap) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Button(action: onProfileTap) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.appAccent)
                    )
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

#Preview {
    HeaderTopBar(
        currentMonth: "October",
        onMonthPickerTap: {},
        onProfileTap: {}
    )
    .background(Color.appPrimary)
}
