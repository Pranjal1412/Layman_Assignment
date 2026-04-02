//
//  ArticleRepository.swift
//  Layman
//
//  Created by Codex on 02/04/26.
//

import Foundation
import Supabase

protocol ArticleRepositoryProtocol {
    func saveArticle(_ article: NewsArticle) async throws
    func fetchSavedArticles() async throws -> [NewsArticle]
    func deleteSavedArticle(_ article: NewsArticle) async throws
}

struct ArticleRepository: ArticleRepositoryProtocol {
    func saveArticle(_ article: NewsArticle) async throws {
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id else {
            throw RepositoryError.missingUser
        }

        try await SupabaseManager.shared.client
            .from("saved_articles")
            .insert([
                "user_id": userId.uuidString,
                "title": article.title,
                "link": article.link,
                "description": article.description ?? "",
                "pub_date": article.pubDate,
                "source_name": article.source_name,
                "image_url": article.image_url ?? "",
                "category": article.category.joined(separator: ", ")
            ])
            .execute()
    }

    func fetchSavedArticles() async throws -> [NewsArticle] {
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id else {
            throw RepositoryError.missingUser
        }

        let response: [SavedArticle] = try await SupabaseManager.shared.client
            .from("saved_articles")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value

        return response.map {
            NewsArticle(
                id: UUID(),
                dbId: $0.id.uuidString,
                title: $0.title,
                link: $0.link,
                description: $0.description,
                pubDate: $0.pub_date,
                source_name: $0.source_name ?? "",
                image_url: $0.image_url,
                category: $0.category.components(separatedBy: ", ")
            )
        }
    }

    func deleteSavedArticle(_ article: NewsArticle) async throws {
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id else {
            throw RepositoryError.missingUser
        }
        guard let articleDbId = article.dbId else {
            throw RepositoryError.missingArticleIdentifier
        }

        _ = try await SupabaseManager.shared.client
            .from("saved_articles")
            .delete()
            .eq("id", value: articleDbId)
            .eq("user_id", value: userId.uuidString)
            .execute()
    }
}

enum RepositoryError: LocalizedError {
    case missingUser
    case missingArticleIdentifier

    var errorDescription: String? {
        switch self {
        case .missingUser:
            return "No authenticated user was found."
        case .missingArticleIdentifier:
            return "The selected article could not be identified."
        }
    }
}
