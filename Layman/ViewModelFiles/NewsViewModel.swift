//
//  NewsViewModel.swift
//  Layman
//
//  Created by Pranjal Shinde on 01/04/26.
//

import SwiftUI
import Combine

class NewsViewModel: ObservableObject {
    @Published var featuredArticles: [NewsArticle] = []
    @Published var todaysPicks: [NewsArticle] = []

    private let urlString = "https://newsdata.io/api/1/latest?apikey=pub_3be55bba17f748d3b26e6bcbe6f138fb&q=business,technology&country=in,us,cn&language=en&category=business,technology&prioritydomain=medium&image=1&video=0&removeduplicate=1&excludefield=source_id,source_url,source_icon,source_priority,video_url,pubdatetz,content,language,ai_tag,sentiment,sentiment_stats,ai_region,ai_org,ai_summary,duplicate"

    func loadNews() {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }

            do {
                let response = try JSONDecoder().decode([NewsArticle].self, from: data)
                
                // Example: split first 3 as featured, rest as picks
                DispatchQueue.main.async {
                    self.featuredArticles = Array(response.prefix(3))
                    self.todaysPicks = Array(response.dropFirst(3))
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
}


