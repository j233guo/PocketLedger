//
//  BarChartView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-31.
//

import Charts
import SwiftUI

struct MonoBarChartView: View {
    let data: [MonoChartData]
    let width: CGFloat
    let height: CGFloat
    
    init(data: [MonoChartData], width: CGFloat = 300,  height: CGFloat = 60) {
        self.data = data
        self.width = width
        self.height = height
    }
        
    var body: some View {
        Chart(data) {
            BarMark(
                x: .value($0.category, $0.value)
            )
            .foregroundStyle($0.color)
        }
        .frame(width: width, height: height)
    }
}

#Preview {
    let data = [
        MonoChartData(category: "Expense", value: 800, color: .orange),
        MonoChartData(category: "Budget", value: 3200, color: .blue),
    ]
    MonoBarChartView(data: data)
}
