//
//  ModelFile.swift
//  Layman
//
//  Created by Pranjal Shinde on 01/04/26.
//

import Foundation

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
    let pub_date: String
    let source_name: String?
    let image_url: String?
    let category: String
}
