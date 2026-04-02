//
//  ArticleScreen.swift
//  Layman
//
//  Created by Pranjal Shinde on 31/03/26.
//

import SwiftUI
import Kingfisher

struct ArticleScreen: View {
    
    @StateObject private var viewModel = NewsViewModel()
    @State private var animateContent = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                Layman_NavBar(title: "Layman", hideSearch: false)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        FeaturedCarousel(articles: viewModel.featuredArticles, viewModel: viewModel)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 24)
                        TodaysPicksSection(articles: viewModel.todaysPicks, viewModel: viewModel)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 32)
                    }
                    .padding(.bottom, 24)
                }
            }
            .background(Color.viewBackground)
            .onAppear {
                animateContent = false
                withAnimation(.easeOut(duration: 0.6)) {
                    animateContent = true
                }
                if viewModel.featuredArticles.isEmpty {
                    viewModel.loadNews()
                }
            }
        }
    }
}

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
                        .background(Color.cellBackground)
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
    @ObservedObject var viewModel: NewsViewModel
    
    @State private var currentPage = 1
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        VStack(spacing: 15) {
            TabView(selection: $currentPage) {
                ForEach(Array(articles.enumerated()), id: \.offset) { index, article in
                    NavigationLink(destination: ContentScreenView(article: article)) {
                        FeaturedArticleCard(article: article)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 8)
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 250)
            .onChange(of: currentPage) { oldValue, newValue in
                hapticFeedback.impactOccurred()
                print("Changed from \(oldValue) to \(newValue)")
            }

            HStack(spacing: 6) {
                ForEach(0..<articles.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? Color.accent : Color.primaryText.opacity(0.2))
                        .frame(width: index == currentPage ? 18 : 6, height: 6)
                        .animation(.spring(), value: currentPage)
                }
            }
        }
        .onAppear {
            if articles.count > 1 {
                currentPage = 1
            } else {
                currentPage = 0
            }
        }
    }
}

// MARK: - Featured Article Card (Updated Design)

struct FeaturedArticleCard: View {
    let article: NewsArticle

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { geo in
                // Image layer
                if let urlString = article.image_url, let url = URL(string: urlString) {
                    KFImage(url)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.accent.opacity(0.8))
                }
                
                // Legibility Gradient (Solves the "White Photo" issue)
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }

            VStack(alignment: .leading, spacing: 12) {
                // Logo/Category Box (Layman style)
                Text(article.category.first?.uppercased() ?? "NEWS")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.accent.opacity(0.2))
                    .cornerRadius(10)
                
                // Conversational Headline
                Text(article.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24)) // Smoother corners
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Today's Picks Section

struct TodaysPicksSection: View {
    let articles: [NewsArticle]
    @ObservedObject var viewModel: NewsViewModel
    
    private var displayedArticles: [NewsArticle] {
        showAll ? articles : Array(articles.prefix(3))
    }
    
    @State private var animateRows = false
    @State private var showAll = false

    var body: some View {
        VStack(spacing: 0) {
            // Section Header
            HStack {
                Text("Today's Picks")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.primaryText)

                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showAll.toggle()
                    }
                }) {
                    Text(showAll ? "Show Less" : "View All")
                        .underline()
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.accent)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            // Article List
            VStack(spacing: 8) {
                ForEach(Array(displayedArticles.enumerated()), id: \.element.id) { index, article in
                    NavigationLink(destination: ContentScreenView(article: article)) {
                        ArticleRow(article: article)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .opacity(animateRows ? 1 : 0)
                    .offset(y: animateRows ? 0 : 22)
                    .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.05), value: animateRows)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
            .background(Color.viewBackground)
            .cornerRadius(16)
        }
        .onAppear {
            animateRows = true
        }
        .onChange(of: articles.count) { _, newValue in
            guard newValue > 0 else { return }
            animateRows = false
            withAnimation(.easeOut(duration: 0.45)) {
                animateRows = true
            }
        }
    }
}

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
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 20))

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
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.cellBackground)
        )
        .padding(.horizontal, 16)
    }
}
