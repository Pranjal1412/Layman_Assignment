//
//  ContentScreenView.swift
//  Layman
//
//  Created by Pranjal Shinde on 01/04/26.
//

import SwiftUI
import Kingfisher

struct ContentScreenView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isSaved: Bool
    @State private var currentPage = 0
    @State private var showOriginalArticle = false
    
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    let article: NewsArticle
    
    let backgroundColor = Color.viewBackground
    let primaryTextColor = Color.primaryText
    let accentColor = Color.accent

    init(article: NewsArticle, isSaved: Bool = false) {
        self.article = article
        self._isSaved = State(initialValue: isSaved)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 1. Navigation Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(primaryTextColor)
                        .frame(width: 38, height: 38)
                        .background(Color(red: 0.95, green: 0.93, blue: 0.90))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: { showOriginalArticle = true }) {
                        Image(systemName: "link")
                    }
                    Button(action: {
                        isSaved.toggle()
                        hapticFeedback.impactOccurred()
                    }) {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .foregroundColor(isSaved ? accentColor : primaryTextColor)
                    }
                    Button(action: { shareArticle() }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(primaryTextColor)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)

            // 2. Scrollable Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Headline
                    Text(article.title)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(primaryTextColor)
                        .lineLimit(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)

                    // Image
                    if let urlString = article.image_url, let url = URL(string: urlString) {
                        KFImage(url)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 240)
                            .frame(maxWidth: UIScreen.main.bounds.width - 40)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .clipped()
                    }

                    // Content Cards
                    VStack(spacing: 18) {
                        TabView(selection: $currentPage) {
                            ForEach(0..<3) { index in
                                VStack(alignment: .leading, spacing: 14) {
                                    Text(getSnippet(for: index))
                                        .font(.system(size: 18, weight: .medium))
                                        .lineSpacing(4)
                                        .foregroundColor(primaryTextColor.opacity(0.9))
                                    Spacer()
                                }
                                .padding(25)
                                .frame(maxWidth: .infinity)
                                .frame(height: 190)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .padding(.horizontal, 20)
                                .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 210)
                        .onChange(of: currentPage) { oldValue, newValue in
                            hapticFeedback.impactOccurred()
                        }
                        // Dots
                        HStack(spacing: 6) {
                            ForEach(0..<3) { index in
                                Capsule()
                                    .fill(index == currentPage ? accentColor : primaryTextColor.opacity(0.2))
                                    .frame(width: index == currentPage ? 18 : 6, height: 6)
                                    .animation(.spring(), value: currentPage)
                            }
                        }
                    }
                }
                .padding(.bottom, 20) // Some padding before the fixed button area
            }

            // 3. Fixed Bottom Button Area
            VStack {
                Button(action: { hapticFeedback.impactOccurred() }) {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                        Text("Ask Layman")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(accentColor)
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 10) // Extra padding for safe area
            }
            // Ensures button stays pinned and background fills the notch area
        }
        .background(backgroundColor)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showOriginalArticle) {
            OriginalArticlePopup(article: article)
        }
    }
    
    private func getSnippet(for index: Int) -> String {
        return "xAI recently raised $6 billion, is now raising another $4.3 billion, and plans to compete with OpenAI, Google, and others by training AI that anyone can use and build on."
    }

    private func shareArticle() {
        guard let url = URL(string: article.link) else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Original Article Popup
struct OriginalArticlePopup: View {
    @Environment(\.dismiss) var dismiss
    let article: NewsArticle

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(article.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(article.description ?? "No description available.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    if let url = URL(string: article.link) {
                        Link(destination: url) {
                            Text("Read full article")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Original Article")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}
