//
//  ContentView.swift
//  Layman
//
//  Created by Pranjal Shinde on 31/03/26.
//

import SwiftUI
import UIKit

struct WelcomeScreen: View {
    @Environment(\.colorScheme) private var colorScheme

    var onContinue: () -> Void
    
    @StateObject private var viewModel = WelcomeViewModel()
    @State private var navigate = false
    @State private var animateIn = false
    
    var titleText: AttributedString {
        var text = AttributedString("Business, tech & startups\nmade simple")
        
        text.font = .system(size: 35, weight: .bold)
        text.foregroundColor = Color("PrimaryTextColor")
        
        if let range = text.range(of: "made simple") {
            text[range].foregroundColor = Color("AccentColor")
        }
        
        return text
    }
    
    var body: some View {
        NavigationStack {
            ZStack {

                backgroundGradient
                .ignoresSafeArea()
                
                VStack {
                    
                    // MARK: Top
                    Text("Layman")
                        .font(.system(size: 55, weight: .bold))
                        .foregroundColor(Color("PrimaryTextColor"))
                        .padding(.top, 60)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : -24)
                    
                    Spacer()
                    
                    // MARK: Middle (AttributedString)
                    Text(titleText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 15)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 18)
                    
                    Spacer()
                    
                    swipeButton
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 28)
                }
                .padding(.bottom, 40)
                .animation(.easeOut(duration: 0.6), value: animateIn)
                
            }
            .navigationDestination(isPresented: $navigate) {
                AuthScreen()
            }
            .onChange(of: viewModel.isCompleted) { _, newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            navigate = true
                        }
                    }
                }
            }
            .onAppear {
                viewModel.resetState()
                animateIn = false
                withAnimation(.easeOut(duration: 0.7)) {
                    animateIn = true
                }
            }
        }
    }
    
    var swipeButton: some View {
        ZStack(alignment: .leading) {
            
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.accent)
                .frame(height: 60)
            
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.white.opacity(0.3))
                .frame(width: viewModel.dragOffset + 60, height: 60)
            
            Text("Swipe to get started")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
            
            ZStack {
                Circle()
                    .fill(Color.white)
                
                Image(systemName: "chevron.forward.2")
                    .foregroundColor(Color("AccentColor"))
            }
            .frame(width: 50, height: 50)
            .offset(x: viewModel.dragOffset + 5)
            .gesture(
                DragGesture()
                    .onChanged { viewModel.updateDrag($0)}
                    .onEnded { _ in viewModel.endDrag()
                        if viewModel.isCompleted {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        }

                    }
            )

        }
        .padding(.horizontal, 30)
    }

    private var backgroundGradient: LinearGradient {
        let topColor = colorScheme == .dark
            ? Color(red: 0.22, green: 0.17, blue: 0.14)
            : Color(red: 0.906, green: 0.784, blue: 0.706)
        let centerColor = colorScheme == .dark ? Color.viewBackground : .white

        return LinearGradient(
            gradient: Gradient(stops: [
                .init(color: topColor, location: 0.0),
                .init(color: centerColor, location: 0.5),
                .init(color: topColor, location: 1.0)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}


#Preview {
//    WelcomeScreen()
}
