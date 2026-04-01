//
//  NewsViewModel.swift
//  Layman
//
//  Created by Pranjal Shinde on 01/04/26.
//

import SwiftUI
import Combine

@MainActor
class NewsViewModel: ObservableObject {
    
    @Published var featuredArticles: [NewsArticle] = []
    @Published var todaysPicks: [NewsArticle] = []
    
    private let urlString = "https://newsdata.io/api/1/latest?apikey=pub_1cbc7f79b2904630be65e5789d729728&country=in,us&language=en&category=business,technology&prioritydomain=medium&image=1&removeduplicate=1&sort=pubdateasc&excludefield=source_id,source_url,source_icon,source_priority,video_url,pubdatetz,content,language,ai_tag,sentiment,sentiment_stats,ai_region,ai_org,duplicate,ai_summary,keywords,creator,country"
    
    func loadNews() {
        print("loadNews called")
        
        Task {
            do {
                guard let url = URL(string: urlString) else {
                    print("Invalid URL")
                    return
                }
                
                let (data, response) = try await URLSession.shared.data(from: url)
                
                // Validate response
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode != 200 {
                    print("Invalid response: \(httpResponse.statusCode)")
                    return
                }
                
                let decoded = try JSONDecoder().decode(NewsResponse.self, from: data)
                
                // STRICT FILTER: Only articles with valid images
                let validArticles = decoded.results.filter {
                    guard let image = $0.image_url,
                          !image.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                          URL(string: image) != nil
                    else {
                        return false
                    }
                    return true
                }
                
                print("Total articles: \(decoded.results.count)")
                print("Valid articles with images: \(validArticles.count)")
                
                // Assign filtered data
                self.featuredArticles = Array(validArticles.prefix(3))
                self.todaysPicks = Array(validArticles.dropFirst(3))
                
            } catch {
                print("Error:", error)
            }
        }
    }
}
