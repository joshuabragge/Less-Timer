//
//  CustomDurationPicker.swift
//  Nothing Timer
//
//  Created by Joshua Bragge on 2025-01-20.
//


// CustomDurationPicker.swift
import SwiftUI

struct CustomDurationPicker: View {
    let title: String
    @Binding var minutes: Int
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Stepper("\(minutes) Minutes", 
                           value: $minutes,
                           in: 1...120)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CustomDurationPicker(
        title: "Test Duration",
        minutes: .constant(5)
    )
}