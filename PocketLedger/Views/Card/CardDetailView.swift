//
//  CardDetailView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-07.
//

import SwiftData
import SwiftUI

fileprivate struct CardPerksListView: View {
    var perks: [CardPerk]
    
    var body: some View {
        Section {
            ForEach(perks) { perk in
                let categoryName = perk.category?.name ?? "Everything"
                Text("\(formattedRewardMultiplier(perk.perkType, perk.value)) \(perk.perkType.rawValue) on \(categoryName)")
            }
        } header: {
            Text("Perks on This card")
        } footer: {
            if perks.isEmpty {
                Text("This card doesn't have any perks registered.")
            }
        }
    }
}

fileprivate struct RecentTransactionListRowView: View {
    let transaction: Transaction
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(transaction.date, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                CategoryLogoView(category: transaction.category, size: 15)
                    .padding(.trailing, 5)
                Text(transaction.category?.name ?? "Uncategorized")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("-\(formatCurrency(double: transaction.amount))")
                    .font(.subheadline)
            }
        }
    }
}

struct CardDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject private var messageService: MessageService
    
    @State private var showEditCardView = false
    @State private var showDeleteConfirmation = false
    
    let card: Card
    
    func deleteCard() {
        modelContext.delete(card)
        do {
            try modelContext.save()
            messageService.create(
                message: "Card deleted successfully",
                type: .success
            )
            dismiss()
        } catch {
            messageService.create(
                message: "Encountered error when saving after deleting card: \(error.localizedDescription)",
                type: .error
            )
        }
    }
    
    private var perksOnCard: [CardPerk] {
        do {
            let cardIDString = card.idString
            let predicate = #Predicate<CardPerk> { perk in
                perk.card.idString == cardIDString
            }
            let descriptor = FetchDescriptor<CardPerk>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.value, order: .reverse)]
            )
            return try modelContext.fetch(descriptor)
        } catch {
            messageService.create(
                message: "Encountered error when fetching perks on card: \(error.localizedDescription)",
                type: .error
            )
            return []
        }
    }
    
    private var recentTransactions: [Transaction] {
        do {
            let cardIDString = card.idString
            let predicate = #Predicate<Transaction> { transaction in
                transaction.card?.idString == cardIDString
            }
            var descriptor = FetchDescriptor<Transaction>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.date)]
            )
            descriptor.fetchLimit = 5
            return try modelContext.fetch(descriptor)
        } catch {
            messageService.create(
                message: "Encountered error when fetching recent transactions on card: \(error.localizedDescription)",
                type: .error
            )
            return []
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    CardLogoView(network: card.paymentNetwork, size: 50.0)
                        .padding(.vertical, 5)
                    Text("\(card.name)")
                        .font(.headline)
                        .padding(.horizontal)
                    Spacer()
                    Text("••••\(card.lastFourDigits)")
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                }
                
                CardPerksListView(perks: perksOnCard)
                
                Section {
                    ForEach(recentTransactions) { transaction in
                        NavigationLink {
                            TransactionDetailView(transaction: transaction)
                        } label: {
                            RecentTransactionListRowView(transaction: transaction)
                        }
                    }
                } header: {
                    Text("Recent Transactions")
                } footer: {
                    if recentTransactions.isEmpty {
                        Text("This card doesn't have any transactions yet.")
                    }
                }
                
                if !recentTransactions.isEmpty {
                    NavigationLink {
                        CardTransactionListView(card: card)
                    } label: {
                        Text("All Transactions on This Card")
                    }
                }
                
                Section {
                    Button("Edit Card") {
                        showEditCardView = true
                    }
                    Button("Remove This Card", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                }
            }
            .navigationTitle(card.name)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showEditCardView) {
                EditCardView(card: card)
            }
            .confirmationDialog("Delete Card", isPresented: $showDeleteConfirmation) {
                Button("Confirm", role: .destructive) {
                    deleteCard()
                }
            } message: {
                Text("This card will be gone forever.")
            }
        }
    }
}

#Preview {
    let card = Card(
        name: "My Credit Card",
        cardType: .credit,
        paymentNetwork: .amex,
        lastFourDigits: "1000",
        perkType: .points
    )
    CardDetailView(card: card)
}
