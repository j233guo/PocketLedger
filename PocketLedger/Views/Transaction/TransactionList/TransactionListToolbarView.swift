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
                        HStack {
                            Image(systemName: "line.3.horizontal.decrease")
                            Text(String(localized: "Filter", table: "TransactionList"))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                }
                
                if withAdd {
                    Button {
                        onAddTransaction()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text(String(localized: "Log Transaction", table: "TransactionList"))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                }
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            
            if filterExpanded {
                HStack(alignment: .center) {
                    Text(String(localized: "Date", table: "TransactionList"))
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
