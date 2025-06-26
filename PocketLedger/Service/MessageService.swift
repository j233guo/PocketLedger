//
//  MessageManager.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-14.
//

import SwiftUI
import UIKit

enum MessageType {
    case success, error, warning, info
}

final class MessageService: ObservableObject {
    @Published var show: Bool = false
    @Published var message: String = ""
    @Published var type: MessageType = .success
    
    private var feedbackGenerator = UINotificationFeedbackGenerator()
    private var dismissTimer: Timer?
    
    func create(message: String, type: MessageType, duration: TimeInterval = 3) {
        // Cancel previous timer if exists
        dismissTimer?.invalidate()
        
        DispatchQueue.main.async {
            self.message = message
            self.type = type
            
            withAnimation(.easeOut(duration: 0.5)) {
                self.show = true
            }
            
            switch type {
            case .success:
                self.feedbackGenerator.notificationOccurred(.success)
            case .error:
                self.feedbackGenerator.notificationOccurred(.error)
            case .warning:
                self.feedbackGenerator.notificationOccurred(.warning)
            default:
                return
            }
            
            self.dismissTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
                DispatchQueue.main.async {
                    withAnimation(.easeIn(duration: 0.25)) {
                        self.show = false
                    }
                }
            }
        }
    }
    
    func dismiss() {
        dismissTimer?.invalidate()
        DispatchQueue.main.async {
            self.show = false
        }
    }
}
