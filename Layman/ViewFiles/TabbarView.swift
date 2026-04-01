//
//  TabbarView.swift
//  Layman
//
//  Created by Pranjal Shinde on 01/04/26.
//

import SwiftUI
// MARK: - Articles Screen

struct TabbarView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ArticleScreen()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            SavedArticleScreen()
                .tabItem { Label("Saved", systemImage: "bookmark") }
                .tag(1)

            UserProfileScreen()
                .tabItem { Label("Profile", systemImage: "person") }
                .tag(2)
        }
        .accentColor(Color.accent)
    }
}
