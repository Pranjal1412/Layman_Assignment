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

    func fetch() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

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
