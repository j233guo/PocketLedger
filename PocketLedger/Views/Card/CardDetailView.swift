//
//  CardDetailView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-07.
//

import SwiftData
import SwiftUI

private struct CardPerksListView: View {
    var perks: [CardPerk]
    
    var body: some View {
        Section {
            ForEach(perks) { perk in
                CardPerkListRowView(perk: perk)
            }
        } header: {
            Text(String(localized: "Perks on This card", table: "CardDetail"))
        } footer: {
            if perks.isEmpty {
                Text(String(localized: "This card doesn't have any perks registered.", table: "CardDetail"))
            }
        }
    }
}

struct CardPerkListRowView: View {
    var perk: CardPerk
    
    var body: some View {
        HStack {
            CategoryIconView(category: perk.category)
                .padding(.trailing, 5)
            Text(perk.category?.displayName ?? String(localized: "Everything", table: "Category"))
                .font(.subheadline)
                .fontWeight(.semibold)
            Spacer()
            Text("\(formattedRewardMultiplier(perk.perkType, perk.value))  \(perk.perkType.localizedString)")
        }
    }
}

private struct RecentTransactionListRowView: View {
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
                CategoryIconView(category: transaction.category, size: 15)
                    .padding(.trailing, 5)
                Text(transaction.category?.displayName ?? String(localized: "Uncategorized", table: "Category"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("-\(formatCurrency(double: transaction.amount))")
                        .font(.subheadline)
                    if let rewardAmount = rewardAmount {
                        let rewardString = transaction.card?.perkType == .cashback ? 
                            "\(formatCurrency(double: rewardAmount)) \(CardPerkType.cashback.localizedString)" :
                            "\(rewardAmount.decimalStr(2)) \(CardPerkType.points.localizedString)"
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
                message: String(localized: "Card removed successfully", table: "Message"),
                type: .success
            )
            dismiss()
        } catch {
            messageService.create(
                message: String(localized: "Error saving data: \(error.localizedDescription)", table: "Message"),
                type: .error
            )
        }
    }
    
    private var perksOnCard: [CardPerk] {
        do {
            let cardIDString = card.idString
            let predicate = #Predicate<CardPerk> { perk in
                perk.card?.idString == cardIDString
            }
            let descriptor = FetchDescriptor<CardPerk>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.value, order: .reverse)]
            )
            return try modelContext.fetch(descriptor)
        } catch {
            messageService.create(
                message: String(localized: "Error fetching perks on card: \(error.localizedDescription)", table: "Message"),
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
                message: String(localized: "Error fetching recent transactions: \(error.localizedDescription)", table: "Message"),
                type: .error
            )
            return []
        }
    }
    
    private var totalRewardsOnCardString: String {
        guard card.cardType == .credit else { return "0" }
        guard card.transactions != nil else { return "0" }
        let totalValue: Double = card.transactions!.reduce(0.0) {
            $0 + calculateReward(card: card, transaction: $1)
        }
        return totalValue.decimalStr(2)
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
                            if let perk = card.perkType {
                                Text(String(localized: "Estimated Reward \(perk.localizedString) with Transactions", table: "CardDetail"))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                let rewardString = perk == .cashback ? "\(formatCurrency(string: totalRewardsOnCardString))" : "\(totalRewardsOnCardString)"
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
                    Text(String(localized: "Recent Transactions", table: "CardDetail"))
                } footer: {
                    if recentTransactions.isEmpty {
                        Text(String(localized: "This card doesn't have any transactions yet.", table: "CardDetail"))
                    }
                }
                
                if !recentTransactions.isEmpty {
                    NavigationLink {
                        CardTransactionListView(card: card)
                    } label: {
                        Text(String(localized: "All Transactions on This Card", table: "CardDetail"))
                    }
                }
                
                Section {
                    Button(String(localized: "Edit Card", table: "CardDetail")) {
                        showEditCardView = true
                    }
                    Button(String(localized: "Remove This Card", table: "CardDetail"), role: .destructive) {
                        showDeleteConfirmation = true
                    }
                }
            }
            .navigationTitle(card.name)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showEditCardView) {
                EditCardView(card: card)
            }
            .confirmationDialog(String(localized: "Remove Card", table: "CardDetail"), isPresented: $showDeleteConfirmation) {
                Button(String(localized: "Confirm", table: "Common"), role: .destructive) {
                    deleteCard()
                }
            } message: {
                Text(String(localized: "This card will be gone forever.", table: "CardDetail"))
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
