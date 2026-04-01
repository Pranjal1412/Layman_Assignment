//
//  RootView.swift
//  Layman
//
//  Created by Pranjal Shinde on 31/03/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showWelcome = false
    
    var body: some View {
        Group {
            if authVM.isAuthenticated {
                TabbarView(onSignOut: {
                    withAnimation { showWelcome = true } // <- now TabbarView can call this
                })
                .environmentObject(authVM)
            } else if showWelcome {
                WelcomeScreen {
                    withAnimation { showWelcome = false }
                }
            } else {
                AuthScreen()
            }
        }
        .task {
            await authVM.checkSession()
            if !authVM.isAuthenticated {
                withAnimation { showWelcome = true }
            }
        }
    }
}
