//
//  PocketLedgerApp.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import SwiftData
import SwiftUI

@main
struct PocketLedgerApp: App {
    let messageService = MessageService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(messageService)
                .modelContainer(for: [Transaction.self, TransactionCategory.self, Card.self, CardPerk.self])
        }
    }
}

func createPreviewModelContainer() -> ModelContainer? {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Transaction.self, TransactionCategory.self, Card.self, CardPerk.self, configurations: config)
        return container
    } catch {
        return nil
    }
}
