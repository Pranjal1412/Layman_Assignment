//
//  ContentViewModel.swift
//  Layman
//
//  Created by Codex on 02/04/26.
//

import Foundation
import Combine

final class ContentViewModel: ObservableObject {
    @Published var isSaved: Bool
    @Published var errorMessage: String?
    @Published var laymanContent: LaymanContent?
    @Published var isLoadingLayman: Bool = false

    let article: NewsArticle
    private let articleRepository: ArticleRepositoryProtocol
    private let laymanService = LaymanTransformService()

    init(
        article: NewsArticle,
        isInitiallySaved: Bool = false,
        initialLaymanContent: LaymanContent? = nil,
        articleRepository: ArticleRepositoryProtocol = ArticleRepository()
    ) {
        self.article = article
        self.isSaved = isInitiallySaved
        self.laymanContent = initialLaymanContent
        self.articleRepository = articleRepository
    }

    var snippets: [String] {
        if let cards = laymanContent?.cards, !cards.isEmpty {
            return cards
        }
        return Array(repeating: "Simplifying this story for you...", count: 3)
    }

    var displayHeadline: String {
        laymanContent?.headline ?? article.title
    }

    func fetchLaymanContent() {
        guard laymanContent == nil, !isLoadingLayman else { return }
        isLoadingLayman = true

        Task {
            do {
                let content = try await laymanService.fetchLaymanContent(
                    title: article.title,
                    description: article.description
                )
                await MainActor.run {
                    self.laymanContent = content
                    self.isLoadingLayman = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingLayman = false
                }
                print("Layman fetch error:", error)
            }
        }
    }
    
    func toggleSaved() async -> Bool {
        let previousValue = isSaved
        isSaved.toggle()
        errorMessage = nil

        do {
            if isSaved {
                try await articleRepository.saveArticle(article)
            } else {
                try await articleRepository.deleteSavedArticle(article)
            }
            return true
        } catch {
            isSaved = previousValue
            errorMessage = error.localizedDescription
            return false
        }
    }

//    private func makeSnippets(from description: String?, maxCards: Int = 3) -> [String] {
//        guard let description, !description.isEmpty else {
//            return ["No description available."]
//        }
//
//        let sentences = description
//            .components(separatedBy: CharacterSet(charactersIn: ".!?"))
//            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//            .filter { !$0.isEmpty }
//
//        guard !sentences.isEmpty else {
//            return [description]
//        }
//
//        let numberOfCards = min(maxCards, sentences.count)
//        let partSize = max(1, sentences.count / numberOfCards)
//
//        return (0..<numberOfCards).map { index in
//            let startIndex = index * partSize
//            let endIndex = index == numberOfCards - 1
//                ? sentences.count
//                : min(startIndex + partSize, sentences.count)
//            let snippetSentences = sentences[startIndex..<endIndex]
//            return snippetSentences.joined(separator: ". ") + (endIndex != sentences.count ? "." : "")
//        }
//    }
}
