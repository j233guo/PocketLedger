//
//  MonthlyBudgetView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-31.
//

import SwiftData
import SwiftUI

struct MonthlyBudgetView: View {
    @AppStorage("monthlyBudget") private var monthlyBudget: Double = 1000.0
    
    @Query private var transactions: [Transaction]
    
    @State private var expandEditBudget = false
    @State private var newBudget: Double = 1000.0
    
    @FocusState private var budgetFieldFocused: Bool
    
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
    
    private var totalMonthlyExpense: Double {
        transactions.reduce(0.0) { result, transaction in
            result + transaction.amount
        }
    }
    
    private var budgetExceeded: Bool {
        totalMonthlyExpense > monthlyBudget
    }
    
    private var chartData: [MonoChartData] {
        let expenseColor = budgetExceeded ? Color.red : Color("ExpenseColor")
        return [
            MonoChartData(
                category: "Expense",
                value: totalMonthlyExpense,
                color: expenseColor
            ),
            MonoChartData(
                category: "Remaining Budget",
                value: monthlyBudget - totalMonthlyExpense,
                color: .blue
            )
        ]
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text(String(localized: "Monthly Budget", table: "Home"))
                    .font(.headline)
                
                if budgetExceeded {
                    let exceededAmount = formatCurrency(double: -(monthlyBudget - totalMonthlyExpense))
                    Text(String(localized: "You have exceeded your budget by \(exceededAmount).", table: "Home"))
                        .padding(.top, 5)
                        .frame(maxWidth: .infinity)
                } else {
                    let expense = formatCurrency(double: totalMonthlyExpense)
                    let budget = formatCurrency(double: monthlyBudget)
                    Text(String(localized: "You've spent \(expense) of your \(budget) budget.", table: "Home"))
                        .padding(.top, 5)
                        .frame(maxWidth: .infinity)
                }
                
                Group {
                    GeometryReader { geometry in
                        HStack {
                            Spacer()
                            MonoBarChartView(data: chartData, width: geometry.size.width * 0.8, height: 35)
                            Spacer()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                
                
                if expandEditBudget {
                    VStack(alignment: .center) {
                        Text(String(localized: "New Budget", table: "Home"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        HStack {
                            Spacer()
                            Button {
                                newBudget -= 10
                            } label: {
                                Image(systemName: "minus")
                                    .frame(width: 20, height: 20)
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.circle)
                            TextField(String(localized: "Budget", table: "Home"), value: $newBudget, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                .kerning(2.0)
                                .font(.title)
                                .fontWeight(.semibold)
                                .fontDesign(.monospaced)
                                .multilineTextAlignment(.center)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($budgetFieldFocused)
                                .keyboardType(.decimalPad)
                            Button {
                                newBudget += 10
                            } label: {
                                Image(systemName: "plus")
                                    .frame(width: 20, height: 20)
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.circle)
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            Button {
                                monthlyBudget = newBudget
                                withAnimation(.easeInOut) {
                                    expandEditBudget = false
                                }
                            } label: {
                                Text(String(localized: "Set Budget", table: "Home"))
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                        }
                    }
                } else {
                    HStack {
                        Spacer()
                        Button {
                            newBudget = monthlyBudget
                            withAnimation(.easeInOut) {
                                expandEditBudget = true
                            }
                        } label: {
                            Text(String(localized: "Edit Budget", table: "Home"))
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button {
                            budgetFieldFocused = false
                        } label: {
                            Text(String(localized: "Done", table: "Common")).bold()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            MonthlyBudgetView()
                .padding(.vertical)
        }
        .listStyle(.plain)
    }
}
