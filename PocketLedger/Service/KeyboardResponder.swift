//
//  KeyboardResponder.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-04-01.
//

import Combine
import SwiftUI

/// Observes and publishes the visibility state of the software keyboard.
///
/// This class subscribes to system keyboard notifications (`keyboardWillShowNotification` and `keyboardWillHideNotification`)
/// and maintains an observable `isVisible` property that reflects the current keyboard state.
///
/// ## Usage
/// 1. Add `@StateObject private var keyboardResponder = KeyboardResponder()` to your view
/// 2. Conditionally hide views when `keyboardResponder.isVisible` is true
///
/// - Important: This class must be used as an `@StateObject` in SwiftUI views to maintain proper lifecycle.
/// - Note: The observation begins immediately upon initialization and continues until deallocated.
/// - Warning: Do not create multiple instances for the same view hierarchy as it may cause performance issues.
///
/// ## Example
/// ```
/// if !keyboardResponder.isVisible {
///     CustomBottomBar()
/// }
/// ```
final class KeyboardResponder: ObservableObject {
    @Published var isVisible: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { _ in
                self.isVisible = true
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { _ in
                self.isVisible = false
            }
            .store(in: &cancellables)
    }
}
