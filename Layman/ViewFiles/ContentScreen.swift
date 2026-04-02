//
//  ContentScreenView.swift
//  Layman
//
//  Created by Pranjal Shinde on 01/04/26.
//

import SwiftUI
import Kingfisher
import SafariServices

struct ContentScreenView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: ContentViewModel
    @State private var currentPage = 0
    @State private var showOriginalArticle = false
    @State private var showAskLayman = false
    @State private var animateContent = false

    var savedArticlesVM: SavedArticlesViewModel?  
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    let article: NewsArticle
    
    let backgroundColor = Color.viewBackground
    let primaryTextColor = Color.primaryText
    let accentColor = Color.accent

    init(
        article: NewsArticle,
        isSaved: Bool = false,
        preloadedLaymanContent: LaymanContent? = nil,
        savedArticlesVM: SavedArticlesViewModel? = nil
    ) {
        self.article = article
        self._viewModel = StateObject(
            wrappedValue: ContentViewModel(
                article: article,
                isInitiallySaved: isSaved,
                initialLaymanContent: preloadedLaymanContent
            )
        )
        self.savedArticlesVM = savedArticlesVM
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
                        .background(Color.cellBackground)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: { showOriginalArticle = true }) {
                        Image(systemName: "link")
                    }
                    .sheet(isPresented: $showOriginalArticle) {
                        if let url = URL(string: article.link) {
                            SafariView(url: url)
                                .edgesIgnoringSafeArea(.all)
                        } else {
                            Text("Invalid URL")
                        }
                    }
                    
                    //bookmark button
                    Button(action: {
                        Task {
                            await MainActor.run {
                                authVM.updateStreak()
                            }
                            let didUpdate = await viewModel.toggleSaved()
                            if didUpdate && !viewModel.isSaved {
                                savedArticlesVM?.removeFromList(article)
                            }
                            hapticFeedback.impactOccurred()
                        }
                    }) {
                        Image(systemName: viewModel.isSaved ? "bookmark.fill" : "bookmark")
                            .foregroundColor(viewModel.isSaved ? accentColor : primaryTextColor)
                    }
                    
                    //share button
                    Button(action: {
                        shareArticle()
                        authVM.updateStreak()
                    }) {
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
                    Text(viewModel.displayHeadline)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(primaryTextColor)
                        .lineLimit(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 18)

                    // Image
                    if let urlString = article.image_url, let url = URL(string: urlString) {
                        KFImage(url)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 240)
                            .frame(maxWidth: UIScreen.main.bounds.width - 40)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .clipped()
                            .opacity(animateContent ? 1 : 0)
                            .scaleEffect(animateContent ? 1 : 0.96)
                    }

                    // Content Cards
                    VStack(spacing: 18) {
                        let snippets = viewModel.snippets

                        TabView(selection: $currentPage) {
                            ForEach(0..<snippets.count, id: \.self) { index in
                                VStack(alignment: .leading) {
                                    Spacer()
                                    Text(snippets[index])
                                        .font(.system(size: 18, weight: .medium))
                                        .lineSpacing(4)
                                        .foregroundColor(primaryTextColor.opacity(0.9))
                                    Spacer()
                                }
                                .padding(20)
                                .frame(maxWidth: .infinity)
                                .frame(height: 190)
                                .background(Color.cellBackground)
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
                            ForEach(Array(snippets.indices), id: \.self) { index in
                                Capsule()
                                    .fill(index == currentPage ? accentColor : primaryTextColor.opacity(0.2))
                                    .frame(width: index == currentPage ? 18 : 6, height: 6)
                                    .animation(.spring(), value: currentPage)
                            }
                        }
                    }
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 6)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 26)
                }
                .padding(.bottom, 20) // Some padding before the fixed button area
            }

            // 3. Fixed Bottom Button Area
            VStack {
                Button(action: {
                    hapticFeedback.impactOccurred()
                    showAskLayman = true  // Trigger the modal
                }) {
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
                .padding(.bottom, 10)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 24)
                .sheet(isPresented: $showAskLayman) {
                    AskLaymanModalView(articleContext: article.description ?? "")
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible) // optional, gives that top bar
                }
            }
            
        }
        .background(backgroundColor)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showOriginalArticle) {
            OriginalArticlePopup(article: article)
        }
        .onAppear {
            animateContent = false
            withAnimation(.easeOut(duration: 0.55)) {
                animateContent = true
            }

            // Only fetch if NOT already prefetched
            if viewModel.laymanContent == nil {
                viewModel.fetchLaymanContent()
            }
        }
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

// 1. SwiftUI wrapper for SFSafariViewController
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariVC = SFSafariViewController(url: url)
        safariVC.dismissButtonStyle = .close
        return safariVC
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) { }
}
