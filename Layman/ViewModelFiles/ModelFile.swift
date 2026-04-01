//
//  ModelFile.swift
//  Layman
//
//  Created by Pranjal Shinde on 01/04/26.
//

import Foundation

struct NewsArticle: Identifiable, Codable {
    var id = UUID()                  // local unique ID for SwiftUI List
    let title: String
    let link: String
    let description: String?
    let pubDate: String
    let source_name: String
    let image_url: String?
    let category: [String]
}

extension NewsArticle {
    static let featuredArticles: [NewsArticle] = []
    static let todaysPicks: [NewsArticle] = []
}
