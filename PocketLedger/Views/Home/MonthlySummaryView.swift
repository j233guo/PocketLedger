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
            messageService.create(
                message: String(localized: "Error filtering income transactions: \(error.localizedDescription)", table: "Message"),
                type: .error
            )
            return []
        }
    }
    
    private var expenseTransactions: [Transaction] {
        do {
            return try transactions.filter { transaction in
                try expenseTransactionPredicate.evaluate(transaction)
            }
        } catch {
            messageService.create(
                message: String(localized: "Error filtering expense transactions: \(error.localizedDescription)", table: "Message"),
                type: .error
            )
            return []
        }
    }
    
    private var incomeChartData: MonoChartData {
        let totalIncome = incomeTransactions.reduce(0.0) { $0 + $1.amount }
        return MonoChartData(category: TransactionType.income.localizedString, value: totalIncome, color: Color("IncomeColor"))
    }
    
    private var expenseChartData: MonoChartData {
        let totalExpense = expenseTransactions.reduce(0.0) { $0 + $1.amount }
        return MonoChartData(category: TransactionType.expense.localizedString, value: totalExpense, color: Color("ExpenseColor"))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(String(localized: "Monthly Summary", table: "Home"))
                .font(.headline)
            if transactions.isEmpty {
                Text(String(localized: "You don’t have any transactions this month yet.", table: "Home"))
                    .font(.subheadline)
                    .padding(.top, 5)
                    .frame(maxWidth: .infinity)
            } else {
                let incomes = formatCurrency(double: incomeChartData.value)
                let expenses = formatCurrency(double: expenseChartData.value)
                Text(String(localized: "You received \(incomes) and spent \(expenses) this month.", table: "Home"))
                    .font(.subheadline)
                    .padding(.top, 5)
                    .frame(maxWidth: .infinity)

                HStack(alignment: .center) {
                    PieChartView(data: [incomeChartData, expenseChartData], size: 100)
                        .padding(.trailing)
                    VStack(alignment: .leading) {
                        HStack {
                            Circle()
                                .foregroundStyle(Color("IncomeColor"))
                                .frame(width: 15, height: 15)
                            Text(TransactionType.income.localizedString)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Circle()
                                .foregroundStyle(Color("ExpenseColor"))
                                .frame(width: 15, height: 15)
                            Text(TransactionType.expense.localizedString)
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
