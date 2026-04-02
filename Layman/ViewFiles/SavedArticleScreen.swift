//
//  SavedArticleScreen.swift
//  Layman
//
//  Created by Pranjal Shinde on 01/04/26.
//

import SwiftUI

struct SavedArticleScreen: View {

    @StateObject private var viewModel = SavedArticlesViewModel()
    @State private var animateList = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 0) {
                    
                    // Top Nav
                    Layman_NavBar(title: "Saved", hideSearch: false)
                    
                    // List
                    if viewModel.savedArticles.isEmpty {
                        VStack {
                            Spacer()
                            
                            Text("No saved articles")
                                .font(.system(size: 20, weight: .light))
                                .foregroundColor(.gray)
                                .opacity(animateList ? 1 : 0)
                                .offset(y: animateList ? 0 : 18)
                            
                            Spacer()
                        }
                        .transition(.opacity)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(Array(viewModel.savedArticles.enumerated()), id: \.element.id) { index, article in
                                    NavigationLink(destination: ContentScreenView(article: article, isSaved: true, savedArticlesVM: viewModel)) {
                                        ArticleRow(article: article)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .opacity(animateList ? 1 : 0)
                                    .offset(y: animateList ? 0 : 20)
                                    .animation(.easeOut(duration: 0.35).delay(Double(index) * 0.04), value: animateList)
                                }
                            }
                            .padding(.top, 4)
                            .padding(.bottom, 20)
                        }
                    }
                }
                .background(.viewBackground)
            }
            // Loader overlay
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                        .scaleEffect(1.5)
                        .padding(30)
                        .background(Color.cellBackground)
                        .cornerRadius(16)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    Spacer()
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.savedArticles.isEmpty)
        .animation(.easeInOut(duration: 0.25), value: viewModel.isLoading)
        .onAppear {
            animateList = false
            Task {
                await viewModel.fetch()
                await MainActor.run {
                    withAnimation(.easeOut(duration: 0.45)) {
                        animateList = true
                    }
                }
            }
        }
    }
}
