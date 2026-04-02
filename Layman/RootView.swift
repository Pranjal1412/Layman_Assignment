//
//  RootView.swift
//  Layman
//
//  Created by Pranjal Shinde on 31/03/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var isCheckingSession = true

    var body: some View {
        ZStack {
            if isCheckingSession {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.accent)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else if authVM.isAuthenticated {
                TabbarView(onSignOut: {
                    Task {
                        await authVM.logout()
                        withAnimation(.easeInOut(duration: 0.35)) {
                            isCheckingSession = false
                        }
                    }
                })
                .environmentObject(authVM)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))
            } else {
                WelcomeScreen {
                    authVM.isAuthenticated = false
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: isCheckingSession)
        .animation(.easeInOut(duration: 0.35), value: authVM.isAuthenticated)
        .task {
            await authVM.checkSession()
            withAnimation(.easeInOut(duration: 0.35)) {
                isCheckingSession = false
            }
        }
    }
}
