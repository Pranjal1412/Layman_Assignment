//
//  WelcomeViewModel.swift
//  Layman
//
//  Created by Pranjal Shinde on 31/03/26.
//

import SwiftUI
import Combine

class WelcomeViewModel: ObservableObject {
    @Published var dragOffset: CGFloat = 0
    @Published var isCompleted: Bool = false
    
    let maxWidth: CGFloat = UIScreen.main.bounds.width - 60
    let threshold: CGFloat = 0.6
    
    func updateDrag(_ value: DragGesture.Value) {
        let translation = value.translation.width
        if translation > 0 {
            dragOffset = min(translation, maxWidth - 60)
        }
    }
    
    func endDrag() {
        let progress = dragOffset / (maxWidth - 60)
        
        if progress > threshold {
            completeSwipe()
        } else {
            reset()
        }
    }
    
    private func completeSwipe() {
        withAnimation(.easeOut(duration: 0.25)) {
            dragOffset = maxWidth - 60
            isCompleted = true
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    private func reset() {
        withAnimation(.easeOut(duration: 0.3)) {
            dragOffset = 0
        }
    }
    
    // Reset the entire swipe state
    func resetState() {
        dragOffset = 0
        isCompleted = false
    }
}
