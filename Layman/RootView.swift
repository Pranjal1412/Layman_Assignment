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
                    .transition(.opacity)
            } else if authVM.isAuthenticated {
                TabbarView(onSignOut: {
                    Task {
                        await authVM.logout()
                        withAnimation {
                            isCheckingSession = false
                        }
                    }
                })
                .environmentObject(authVM)
                .transition(.opacity)
            } else {
                WelcomeScreen {
                    authVM.isAuthenticated = false
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: isCheckingSession)
        .animation(.easeInOut, value: authVM.isAuthenticated)
        .task {
            await authVM.checkSession()
            isCheckingSession = false
        }
    }
}
