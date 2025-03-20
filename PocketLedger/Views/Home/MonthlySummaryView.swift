//
//  MonthlySummaryView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-20.
//

import SwiftData
import SwiftUI

struct MonthlySummaryView: View {
    @EnvironmentObject private var messageService: MessageService
    
    @Query private var transactions: [Transaction]
    
    init() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.day = 1
        let firstDayOfMonth = calendar.date(from: components) ?? Date()
        let today = calendar.startOfDay(for: .now)
        let adjustedEndDate = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let predicate = #Predicate<Transaction> {
            $0.date >= firstDayOfMonth && $0.date < adjustedEndDate
        }
        _transactions = Query(filter: predicate)
    }
    
    private var incomeTransactions: [Transaction] {
        do {
            return try transactions.filter { transaction in
                try incomeTransactionPredicate.evaluate(transaction)
            }
        } catch {
            messageService.create(message: "Error when filtering income transactions: \(error.localizedDescription)", type: .error)
            return []
        }
    }
    
    private var expenseTransactions: [Transaction] {
        do {
            return try transactions.filter { transaction in
                try expenseTransactionPredicate.evaluate(transaction)
            }
        } catch {
            messageService.create(message: "Error when filtering expense transactions: \(error.localizedDescription)", type: .error)
            return []
        }
    }
    
    private var incomeChartData: ChartData {
        let totalIncome = incomeTransactions.reduce(0.0) { $0 + $1.amount }
        return ChartData(category: "Income", value: totalIncome, color: .green)
    }
    
    private var expenseChartData: ChartData {
        let totalExpense = expenseTransactions.reduce(0.0) { $0 + $1.amount }
        return ChartData(category: "Expense", value: totalExpense, color: .orange)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Monthly Summary")
                .font(.headline)
            if transactions.isEmpty {
                Text("You do not have any transactions this month yet.")
                    .padding(.top, 5)
                    .frame(maxWidth: .infinity)
            } else {
                let incomes = formatCurrency(double: incomeChartData.value)
                let expenses = formatCurrency(double: expenseChartData.value)
                Text("You received \(incomes) and spent \(expenses) this month.")
                    .padding(.top, 5)
                    .frame(maxWidth: .infinity)
                HStack(alignment: .center) {
                    PieChartView(data: [incomeChartData, expenseChartData], size: 100)
                        .padding(.trailing)
                    VStack(alignment: .leading) {
                        HStack {
                            Circle()
                                .foregroundStyle(.green)
                                .frame(width: 15, height: 15)
                            Text("Income")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Circle()
                                .foregroundStyle(.orange)
                                .frame(width: 15, height: 15)
                            Text("Expense")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    if let container = createPreviewModelContainer() {
        container.mainContext.insert(DefaultTransactionFactory.expenseExample)
        container.mainContext.insert(DefaultTransactionFactory.incomeExample)
        return List {
            MonthlySummaryView()
                .padding(.vertical)
        }
        .listStyle(.plain)
        .modelContainer(container)
    } else {
        return List {
            MonthlySummaryView()
                .padding(.vertical)
        }
        .listStyle(.plain)
    }
}
