//
//  ModelFile.swift
//  Layman
//
//  Created by Pranjal Shinde on 01/04/26.
//

import Foundation
import Supabase

struct NewsArticle: Identifiable, Codable {
    var id = UUID()              // local Swift UUID for UI
    var dbId: String? = nil           // Supabase row UUID
    let title: String
    let link: String
    let description: String?
    let pubDate: String
    let source_name: String
    let image_url: String?
    let category: [String]

    enum CodingKeys: String, CodingKey {
        case title, link, description, pubDate, source_name, image_url, category
    }
}

extension NewsArticle {
    static let featuredArticles: [NewsArticle] = []
    static let todaysPicks: [NewsArticle] = []
}

struct NewsResponse: Codable {
    let results: [NewsArticle]
}

struct SavedArticle: Identifiable, Codable {
    let id: UUID
    let title: String
    let link: String
    let description: String?
    let pub_date: String   // or Date (better, see below)
    let source_name: String?
    let image_url: String?
    let category: String   // <-- IMPORTANT (not [String])
}

func saveArticle(_ article: NewsArticle) async {
    guard let userId = SupabaseManager.shared.client.auth.currentUser?.id else { return }

    do {
        try await SupabaseManager.shared.client
            .from("saved_articles")
            .insert([
                "user_id": userId.uuidString,
                "title": article.title,
                "link": article.link,
                "description": article.description ?? "",
                "pub_date": article.pubDate, // convert if needed
                "source_name": article.source_name,
                "image_url": article.image_url ?? "",
                "category": article.category.joined(separator: ", ")
            ])
            .execute()
        
        print("Saved successfully")
    } catch {
        print("Error saving article:", error)
    }
}

func fetchSavedArticles() async -> [NewsArticle]? {
    guard let userId = SupabaseManager.shared.client.auth.currentUser?.id else { return nil}

    do {
        let response: [SavedArticle] = try await SupabaseManager.shared.client
            .from("saved_articles")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value

        let mappedArticles: [NewsArticle] = response.map {
            NewsArticle(
                id: UUID(),                     // UI purposes
                dbId: $0.id.uuidString,                    // Supabase row ID
                title: $0.title,
                link: $0.link,
                description: $0.description,
                pubDate: $0.pub_date,
                source_name: $0.source_name ?? "",
                image_url: $0.image_url,
                category: $0.category.components(separatedBy: ", ")
            )
        }
        return mappedArticles
        
    } catch {
        print("Error fetching articles:", error)
        return nil
    }
}

func deleteSavedArticle(_ article: NewsArticle) async {
    guard let userId = SupabaseManager.shared.client.auth.currentUser?.id,
          let articleDbId = article.dbId else { return }

    do {
        _ = try await SupabaseManager.shared.client
            .from("saved_articles")
            .delete()
            .eq("id", value: articleDbId)
            .eq("user_id", value: userId.uuidString)
            .execute()

        print("Deleted successfully")
    } catch {
        print("Delete failed:", error)
    }
}
