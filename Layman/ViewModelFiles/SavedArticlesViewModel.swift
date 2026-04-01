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

    func fetch() async {
        guard let articles = await fetchSavedArticles() else { return }
        DispatchQueue.main.async { self.savedArticles = articles }
    }

    func remove(_ article: NewsArticle) {
        savedArticles.removeAll { $0.id == article.id }
    }
}
