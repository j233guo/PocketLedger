//
//  EditCardView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-07.
//

import SwiftUI

struct EditCardView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var cardName = ""
    @State private var cardType: CardType = .debit
    @State private var paymentNetwork: CardPaymentNetwork = .interac
    @State private var lastFourDigits: String = ""
    @State private var cardPerkType: CardPerkType = .points
    
    @State private var showNameEmptyWarning = false
    @State private var showLastFourDigitsEmptyWarning = false
    
    @FocusState private var nameFieldIsFocused: Bool
    @FocusState private var lastFourDigitsFieldIsFocused: Bool
    
    var card: Card
    
    func save() {
        if cardName.isEmpty {
            showNameEmptyWarning = true
        }
        if lastFourDigits.isEmpty || lastFourDigits.count != 4 {
            showLastFourDigitsEmptyWarning = true
        }
        guard !showNameEmptyWarning && !showLastFourDigitsEmptyWarning else { return }
        card.name = cardName
        cardType = cardType
        card.paymentNetwork = paymentNetwork
        card.lastFourDigits = lastFourDigits
        if card.cardType == .credit {
            card.perkType = cardPerkType
        } else {
            card.perkType = nil
            card.perks = []
        }
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Card Name", text: $cardName)
                        .onChange(of: cardName) {
                            showNameEmptyWarning = false
                        }
                } header: {
                    Text("Nickname for the card")
                } footer: {
                    if showNameEmptyWarning {
                        Text("Please enter a name for the card.")
                            .foregroundStyle(.red)
                    }
                }
                
                Section {
                    Picker("Card Type", selection: $cardType) {
                        Text("Debit").tag(CardType.debit)
                        Text("Credit").tag(CardType.credit)
                    }
                    .onChange(of: cardType) {
                        if cardType == card.cardType {
                            paymentNetwork = card.paymentNetwork
                        } else {
                            if cardType == .debit {
                                paymentNetwork = .interac
                            } else if cardType == .credit {
                                paymentNetwork = .visa
                            }
                        }
                    }
                    
                    if cardType == .credit {
                        Picker("Payment Network", selection: $paymentNetwork) {
                            Text("VISA").tag(CardPaymentNetwork.visa)
                            Text("Mastercard").tag(CardPaymentNetwork.mastercard)
                            Text("American Express").tag(CardPaymentNetwork.amex)
                        }
                    }
                }
                
                Section {
                    TextField("1234", text: Binding(
                        get: { lastFourDigits },
                        set: { newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count <= 4 {
                                lastFourDigits = String(filtered.prefix(4))
                            }
                        }
                    ))
                    .focused($lastFourDigitsFieldIsFocused)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: lastFourDigits) {
                        showLastFourDigitsEmptyWarning = false
                    }
                } header: {
                    Text("Last four digits of the card")
                } footer: {
                    if showLastFourDigitsEmptyWarning {
                        Text("Please enter the last four digits of the card.")
                            .foregroundStyle(.red)
                    } else {
                        Text("For identifying purpose only.")
                    }
                }
                
                if cardType == .credit {
                    Section {
                        Picker("Card Perk Type", selection: $cardPerkType) {
                            Text("Reward Points")
                                .tag(CardPerkType.points)
                            Text("Cash Back")
                                .tag(CardPerkType.cashBack)
                        }
                    }
                }
            }
            .navigationTitle("Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        save()
                    }
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button {
                            if nameFieldIsFocused {
                                nameFieldIsFocused = false
                            }
                            if lastFourDigitsFieldIsFocused {
                                lastFourDigitsFieldIsFocused = false
                            }
                        } label: {
                            Text("Done")
                                .bold()
                        }
                    }
                }
            }
            .onAppear {
                cardName = card.name
                cardType = card.cardType
                paymentNetwork = card.paymentNetwork
                lastFourDigits = card.lastFourDigits
                if let perkType = card.perkType {
                    cardPerkType = perkType
                }
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
    EditCardView(card: card)
}
