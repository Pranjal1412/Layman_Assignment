//
//  HomeScreen.swift
//  Layman
//
//  Created by Pranjal Shinde on 31/03/26.
//

import SwiftUI
import Kingfisher

struct ArticleScreen: View {
    
    @StateObject private var viewModel = NewsViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            Layman_NavBar(title: "Layman", hideSearch: false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Featured Carousel
                    FeaturedCarousel(articles: viewModel.featuredArticles)
                    TodaysPicksSection(articles: viewModel.todaysPicks)
                }
                .padding(.bottom, 24)
            }
        }
        .background(Color.viewBackground)
        .onAppear {
            if viewModel.featuredArticles.isEmpty {
                viewModel.loadNews()
            }
        }
    }
}

// MARK: - Navigation Bar

struct Layman_NavBar: View {
    let title: String
    var hideSearch: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(Color.primaryText)

            Spacer()

            if hideSearch == false {
                Button(action: {
                    // Search action
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.primaryText)
                        .frame(width: 36, height: 36)
                        .background(Color(red: 0.95, green: 0.93, blue: 0.90))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.viewBackground)
    }
}
// MARK: - Featured Carousel

struct FeaturedCarousel: View {
    let articles: [NewsArticle]
    @State private var currentPage = 0

    var body: some View {
        VStack(spacing: 10) {
            TabView(selection: $currentPage) {
                ForEach(Array(articles.enumerated()), id: \.offset) { index, article in
                    FeaturedArticleCard(article: article)
                        .tag(index)
                        .onTapGesture {
                            // Navigate to article detail
                            print("Tapped featured: \(article.title)")
                        }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 220)
            .padding(.horizontal, 20)

            // Page Indicator Dots
            HStack(spacing: 6) {
                ForEach(0..<articles.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.accent : Color.primaryText.opacity(0.25))
                        .frame(width: index == currentPage ? 8 : 6, height: index == currentPage ? 8 : 6)
                        .animation(.spring(response: 0.3), value: currentPage)
                }
            }
        }
    }
}

// MARK: - Featured Article Card

struct FeaturedArticleCard: View {
    let article: NewsArticle

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            // Replace with AsyncImage or Image(article.imageName) for real assets
            GeometryReader { geo in
                Rectangle()
                    .fill(Color.accent.opacity(0.85))
                    .overlay(
                        // Placeholder pattern — replace with actual Image asset
                        ZStack {
                            Color.primaryText.opacity(0.15)
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.2))
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                    )
            }

            // Bottom gradient + text
            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0),
                        Color.black.opacity(0.65)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 110)
                .overlay(
                    VStack(alignment: .leading, spacing: 4) {
                        // Category pill
                        Text("\(Text(article.category.first ?? "News"))")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.25))
                            .cornerRadius(4)

                        // Headline
                        Text(article.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14),
                    alignment: .bottomLeading
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Today's Picks Section

struct TodaysPicksSection: View {
    let articles: [NewsArticle]

    var body: some View {
        VStack(spacing: 0) {
            // Section Header
            HStack {
                Text("Today's Picks")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.primaryText)

                Spacer()
                
                Button(action: {
                    print("View All tapped")
                }) {
                    Text("View All")
                        .underline()
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.accent)
                }

            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            // Article List
            VStack(spacing: 8) {
                ForEach(articles) { article in
                    ArticleRow(article: article)
                        .onTapGesture {
                            print("Tapped article: \(article.title)")
                        }
                }
            }
            .background(Color.white.opacity(0.45))
            .cornerRadius(16)
        }
    }
}

// MARK: - Article Row

struct ArticleRow: View {
    let article: NewsArticle

    var body: some View {
        HStack(spacing: 12) {

            // Thumbnail
            ZStack {
                if let urlString = article.image_url,
                   let url = URL(string: urlString) {
                    
                    KFImage(url)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                else {
                    // fallback to SF Symbol
                    Color.gray.opacity(0.15)

                    Image(systemName: "photo.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 23))

            // Headline
            Text(article.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primaryText)
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 23)
                .fill(Color(red: 0.95, green: 0.93, blue: 0.90))
        )
        .padding(.horizontal, 16)
    }
}

#Preview {
    TabbarView()
}
