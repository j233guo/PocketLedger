//
//  ChartData.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-04-01.
//

import SwiftUI

/// A data structure representing a single-dimensional (1D) chart entry, used for visualizations where each entry is defined by a category and value
///
/// - Properties:
///   - `category`: The label or name of the data category (e.g., "Revenue", "Users").
///   - `value`: The numerical value associated with the category.
///   - `id`: A unique identifier derived from `category` to conform to `Identifiable`.
///   - `color`: The visual color representation of this data point in a chart.
///
/// Used for mono bar charts and pie charts
struct MonoChartData: Identifiable {
    let category: String
    let value: Double
    var id: String { category }
    let color: Color
}
