//
//  LaymanApp.swift
//  Layman
//
//  Created by Pranjal Shinde on 31/03/26.
//

import SwiftUI

@main
struct LaymanApp: App {
    @StateObject private var authVM = AuthViewModel()
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authVM)
        }
    }
}
