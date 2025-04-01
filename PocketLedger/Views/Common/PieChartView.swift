//
//  PieChartView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-20.
//

import Charts
import SwiftUI

struct PieChartView: View {
    let data: [MonoChartData]
    let size: CGFloat
    
    init(data: [MonoChartData], size: CGFloat = 300) {
        self.data = data
        self.size = size
    }
        
    var body: some View {
        Chart(data) {
            SectorMark(
                angle: .value("Value", $0.value),
                innerRadius: .ratio(0.3), // creates a donut chart
                angularInset: 1 // spacing between sectors
            )
            .foregroundStyle($0.color)
            .cornerRadius(size/50) // rounded sector edges
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    let data = [
        MonoChartData(category: "Income", value: 5000, color: .green),
        MonoChartData(category: "Expense", value: 800, color: .orange),
    ]
    PieChartView(data: data)
}
