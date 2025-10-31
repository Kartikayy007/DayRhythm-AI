//
//  MonthPickerView.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import SwiftUI


struct MonthPickerView: View {
    @Binding var selectedMonth: Date
    var onDone: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Select Month")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            DatePicker("", selection: $selectedMonth, displayedComponents: [.date])
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
            
            Button("Done") {
                onDone()
                dismiss()
            }
            .font(.system(size: 18, weight: .semibold))
            .padding(.vertical, 8)
        }
        .padding()
        .presentationDetents([.fraction(0.35)])
        .presentationBackground(.regularMaterial)
    }
}

#Preview {
    MonthPickerView(selectedMonth: .constant(Date())) {
        
    }
}
