//
//  SavedArticleScreen.swift
//  Layman
//
//  Created by Pranjal Shinde on 01/04/26.
//

import SwiftUI

struct SavedArticleScreen: View {

    @StateObject private var viewModel = SavedArticlesViewModel()
    
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
                            
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(viewModel.savedArticles) { article in
                                    NavigationLink(destination: ContentScreenView(article: article, isSaved: true, savedArticlesVM: viewModel)) {
                                        ArticleRow(article: article)
                                    }
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
                    Spacer()
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetch()
            }
        }
    }
}
