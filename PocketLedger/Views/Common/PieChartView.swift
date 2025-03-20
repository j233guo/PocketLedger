//
//  PieChartView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-20.
//

import Charts
import SwiftUI

struct ChartData: Identifiable {
    let category: String
    let value: Double
    var id: String { category }
    let color: Color
}

struct PieChartView: View {
    let data: [ChartData]
    let size: CGFloat
    
    init(data: [ChartData], size: CGFloat = 300) {
        self.data = data
        self.size = size
    }
        
    var body: some View {
        Chart(data) { item in
            SectorMark(
                angle: .value("Value", item.value),
                innerRadius: .ratio(0.3), // creates a donut chart
                angularInset: 1 // spacing between sectors
            )
            .foregroundStyle(item.color)
            .cornerRadius(size/50) // rounded sector edges
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    let chartData = [
        ChartData(category: "Income", value: 5000, color: .green),
        ChartData(category: "Expense", value: 800, color: .orange),
    ]
    PieChartView(data: chartData)
}
