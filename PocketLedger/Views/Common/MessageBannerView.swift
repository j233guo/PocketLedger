//
//  MessageBannerView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-14.
//

import SwiftUI

struct MessageBannerView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var messageService: MessageService
    
    @State private var offset: CGSize = .zero
    
    let message: String
    let type: MessageType
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.95)
    }
    
    private var iconName: String {
        switch type {
        case .success:
            return "checkmark.circle"
        case .error:
            return "xmark.circle"
        case .warning:
            return "exclamationmark.circle"
        case .info:
            return "info.circle"
        }
    }
    
    private var iconColor: Color {
        switch type {
        case .success:
            return .green
        case .error:
            return .red
        case .warning:
            return .orange
        case .info:
            return .blue
        }
    }
    
    var body: some View {
        let dragAmount = offset.width
        let fade = max(0.0, 1.0 - abs(dragAmount) / 150)
        
        HStack {
            Image(systemName: iconName)
                .font(.title)
                .foregroundStyle(iconColor)
                .padding(10)
            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
        }
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 3)
        .padding(.horizontal)
        .offset(x: dragAmount, y: 0)
        .opacity(fade)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { gesture in
                    if abs(gesture.translation.width) > 150 {
                        messageService.dismiss()
                    }
                    offset = .zero
                }
        )
        .animation(.spring(), value: offset)
        
    }
}

#Preview {
    MessageBannerView(message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", type: .success)
    MessageBannerView(message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", type: .error)
    MessageBannerView(message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", type: .warning)
    MessageBannerView(message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", type: .info)
}
