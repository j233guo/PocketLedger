//
//  TransactionListToolbarView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-19.
//

import SwiftUI

struct TransactionListToolbarView: View {
    @Binding var filterExpanded: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var withFilter: Bool
    var withAdd: Bool
    var onAddTransaction: () -> Void = {}
    
    var body: some View {
        VStack {
            HStack {
                if withFilter {
                    Button {
                        withAnimation {
                            filterExpanded.toggle()
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                
                if withAdd {
                    Button {
                        onAddTransaction()
                    } label: {
                        Label("Add Transaction", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .frame(maxWidth: .infinity)
            
            if filterExpanded {
                HStack(alignment: .center) {
                    Text("Date Range")
                        .foregroundStyle(.secondary)
                    DateFilterView(startDate: $startDate, endDate: $endDate)
                }
                .padding(.vertical,5)
            }
            Divider()
        }
        .padding(.horizontal)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    VStack {
        TransactionListToolbarView(
            filterExpanded: .constant(true),
            startDate: .constant(.distantPast),
            endDate: .constant(.now),
            withFilter: true,
            withAdd: true,
            onAddTransaction: {}
        )
        List {}
    }
}
