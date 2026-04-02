//
//  SavedArticlesViewModel.swift
//  Layman
//
//  Created by Pranjal   on 01/04/26.
//

import Foundation
import Combine

final class SavedArticlesViewModel: ObservableObject {
    @Published var savedArticles: [NewsArticle] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let articleRepository: ArticleRepositoryProtocol

    init(articleRepository: ArticleRepositoryProtocol = ArticleRepository()) {
        self.articleRepository = articleRepository
    }

    @MainActor
    func fetch(showLoading: Bool = true) async {
        if showLoading { isLoading = true }
        errorMessage = nil
        defer { if showLoading { isLoading = false } }

        do {
            savedArticles = try await articleRepository.fetchSavedArticles()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeFromList(_ article: NewsArticle) {
        savedArticles.removeAll { $0.id == article.id }
    }
}
