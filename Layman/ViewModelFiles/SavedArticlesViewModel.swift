//
//  SavedArticlesViewModel.swift
//  Layman
//
//  Created by Pranjal   on 01/04/26.
//

import Foundation
import SwiftUI
import Combine

class SavedArticlesViewModel: ObservableObject {
    @Published var savedArticles: [NewsArticle] = []
    @Published var isLoading = false    // Loader state

    func fetch() async {
        DispatchQueue.main.async { self.isLoading = true }  // Start loader

        guard let articles = await fetchSavedArticles() else {
            DispatchQueue.main.async { self.isLoading = false }  // Stop loader on failure
            return
        }

        DispatchQueue.main.async {
            self.savedArticles = articles
            self.isLoading = false   // Stop loader on success
        }
    }

    func remove(_ article: NewsArticle) {
        savedArticles.removeAll { $0.id == article.id }
    }
}
