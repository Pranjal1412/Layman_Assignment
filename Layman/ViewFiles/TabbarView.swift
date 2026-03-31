//
//  TabbarView.swift
//  Layman
//
//  Created by Pranjal Shinde on 01/04/26.
//

import SwiftUI


// MARK: - Models

struct Article: Identifiable {
    let id = UUID()
    let headline: String
    let category: String
    let imageName: String // Use system image or asset name
    let isFeature: Bool
}

// MARK: - Sample Data

extension Article {
    static let featuredArticles: [Article] = [
        Article(headline: "Inside Y Combinator: Where Big Tech gets its start", category: "Y Combinator", imageName: "ycombinator_bg", isFeature: true),
        Article(headline: "OpenAI just raised $40B to build faster chips for ChatGPT", category: "AI", imageName: "openai_bg", isFeature: true),
        Article(headline: "Apple's foldable iPhone is rumored to drop in 2026", category: "Apple", imageName: "apple_bg", isFeature: true),
    ]

    static let todaysPicks: [Article] = [
        Article(headline: "Joby Aviation partners with Delta and Uber to create air taxis", category: "Aviation", imageName: "joby", isFeature: false),
        Article(headline: "Former OpenAI CTO launches Thinking Machines Lab", category: "AI", imageName: "openai_cto", isFeature: false),
        Article(headline: "Apple's first foldable iPhone is rumored to come out in 2026", category: "Apple", imageName: "apple_fold", isFeature: false),
        Article(headline: "Tesla's new Roadster finally has an official release date", category: "Tesla", imageName: "tesla", isFeature: false),
        Article(headline: "Reddit beats Wall Street estimates for the third quarter in a row", category: "Reddit", imageName: "reddit", isFeature: false),
    ]
}

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
