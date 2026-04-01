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
        .onAppear {
            Task {
                await viewModel.fetch()
            }
        }
    }
}
