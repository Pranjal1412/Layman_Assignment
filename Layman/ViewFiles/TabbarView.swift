//
//  TabbarView.swift
//  Layman
//
//  Created by Pranjal Shinde on 01/04/26.
//

import SwiftUI

struct TabbarView: View {
    var onSignOut: (() -> Void)?
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ArticleScreen()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)
            
            SavedArticleScreen()
                .tabItem { Label("Saved", systemImage: "bookmark") }
                .tag(1)
            
            UserProfileScreen(onSignOut: onSignOut) 
                .tabItem { Label("Profile", systemImage: "person") }
                .tag(2)
        }
        .accentColor(Color.accent)
    }
}
