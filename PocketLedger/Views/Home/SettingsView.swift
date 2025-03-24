//
//  SettingsView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-10.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        ManageCategoryView()
                    } label: {
                        Text("Manage Transaction Categories")
                    }
                } header: {
                    Text("Transaction Category")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done", table: "Common")) { dismiss() }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
