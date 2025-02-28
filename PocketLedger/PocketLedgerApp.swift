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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Transaction.self, TransactionCategory.self, Card.self])
        }
    }
}
