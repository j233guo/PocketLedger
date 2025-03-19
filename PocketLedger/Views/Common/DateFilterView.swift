//
//  DateFilterView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-13.
//

import SwiftUI

struct DateFilterView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var body: some View {
        HStack {
            DatePicker("Start", selection: $startDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
            Text("-")
                .foregroundColor(.secondary)
            DatePicker("End", selection: $endDate, in: startDate..., displayedComponents: .date)
                .labelsHidden()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let startDate = Date.now.addingTimeInterval(-24*3600)
    let endDate = Date.now
    return DateFilterView(startDate: .constant(startDate), endDate: .constant(endDate))
}
