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
                CardPerkListRowView(perk: perk)
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

struct CardPerkListRowView: View {
    var perk: CardPerk
    
    var body: some View {
        HStack {
            CategoryLogoView(category: perk.category)
                .padding(.trailing, 5)
            Text(perk.category?.name ?? "Everything")
                .font(.subheadline)
                .fontWeight(.semibold)
            Spacer()
            Text("\(formattedRewardMultiplier(perk.perkType, perk.value))  \(perk.perkType.rawValue)")
        }
    }
}

fileprivate struct RecentTransactionListRowView: View {
    let transaction: Transaction
    
    private var rewardAmount: Double? {
        if let card = transaction.card {
            guard card.cardType == .credit else { return nil }
            return calculateReward(card: card, transaction: transaction)
        } else {
            return nil
        }
    }
    
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
                VStack(alignment: .trailing) {
                    Text("-\(formatCurrency(double: transaction.amount))")
                        .font(.subheadline)
                    if let rewardAmount = rewardAmount {
                        let rewardString = transaction.card?.perkType == .cashback ? "\(formatCurrency(double: rewardAmount)) Cashback" : "\(rewardAmount.twoDecimalString()) Points"
                        Text("+\(rewardString)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
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
    
    private var totalRewardsOnCardString: String {
        guard card.cardType == .credit else { return "0" }
        guard card.transactions != nil else { return "0" }
        var totalValue: Double = 0
        for transaction in card.transactions! {
            totalValue += calculateReward(card: card, transaction: transaction)
        }
        return totalValue.twoDecimalString()
    }
    
    var body: some View {
        NavigationStack {
            List {
                VStack {
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
                    if card.cardType == .credit {
                        Divider()
                        VStack {
                            if let perkName = card.perkType?.rawValue {
                                Text("Estimated Reward \(perkName) with Transactions")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                let rewardString = card.perkType == .cashback ? "\(formatCurrency(string: totalRewardsOnCardString))" : "\(totalRewardsOnCardString)"
                                Text("\(rewardString)")
                                    .font(.title2)
                                    .fontDesign(.monospaced)
                                    .padding(5)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                if card.cardType == .credit {
                    CardPerksListView(perks: perksOnCard)
                }
                
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
