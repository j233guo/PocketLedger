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
    @Published var keyboardVisible: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { _ in true }
        let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in false }
        
        Publishers.Merge(keyboardWillShow, keyboardWillHide)
            .receive(on: RunLoop.main)
            .sink { [weak self] visible in
                // Defer the update to the next run loop iteration
                DispatchQueue.main.async {
                    self?.keyboardVisible = visible
                }
            }
            .store(in: &cancellables)
    }
}
