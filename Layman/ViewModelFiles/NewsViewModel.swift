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
    
    // ✅ ADD
    @Published var laymanContent: [UUID: LaymanContent] = [:]
    @Published var laymanLoadingIds: Set<UUID> = []
    
    private let laymanService = LaymanTransformService()
    
    private let urlString = "https://newsdata.io/api/1/latest?apikey=pub_a3e4ccef886e4f91bb835c9732833b0a&country=in,us&language=en&category=business,technology&prioritydomain=medium&image=1&removeduplicate=1&sort=pubdateasc&excludefield=source_id,source_url,source_icon,source_priority,video_url,pubdatetz,content,language,ai_tag,sentiment,sentiment_stats,keywords,creator,ai_region,ai_org,duplicate,ai_summary,country"
    
    func loadNews() {
        Task {
            do {
                guard let url = URL(string: urlString) else { return }
                
                let (data, response) = try await URLSession.shared.data(from: url)
                
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode != 200 {
                    return
                }
                
                let decoded = try JSONDecoder().decode(NewsResponse.self, from: data)
                
                let validArticles = decoded.results.filter {
                    guard let image = $0.image_url,
                          !image.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                          URL(string: image) != nil
                    else { return false }
                    return true
                }
                
                self.featuredArticles = Array(validArticles.prefix(3))
                self.todaysPicks = Array(validArticles.dropFirst(3))
                
                // PREFETCH (batch first, fallback to single)
                Task {
                    let batch = Array(validArticles.prefix(6))

                    do {
                        let results = try await laymanService.fetchBatchLaymanContent(articles: batch)

                        await MainActor.run {
                            for (id, content) in results {
                                self.laymanContent[id] = content
                            }
                        }

                        // ✅ fallback: check missing ones
                        let missing = batch.filter { self.laymanContent[$0.id] == nil }

                        for article in missing {
                            self.fetchLaymanContent(for: article)
                        }

                    } catch {
                        print("Batch failed, falling back to single:", error)

                        // ✅ full fallback
                        for article in batch {
                            self.fetchLaymanContent(for: article)
                        }
                    }
                }
            } catch {
                print("Error:", error)
            }
        }
    }
    
    // ✅ ADD
    func fetchLaymanContent(for article: NewsArticle) {
        guard laymanContent[article.id] == nil,
              !laymanLoadingIds.contains(article.id) else { return }
        
        laymanLoadingIds.insert(article.id)
        
        Task {
            do {
                let content = try await laymanService.fetchLaymanContent(
                    title: article.title,
                    description: article.description
                )
                
                await MainActor.run {
                    laymanContent[article.id] = content
                    laymanLoadingIds.remove(article.id)
                }
                
            } catch {
                print("Layman fetch error:", error)
                await MainActor.run {
                    laymanLoadingIds.remove(article.id)
                }
            }
        }
    }
    
    func fetchBatchLaymanContent(articles: [NewsArticle]) async throws -> [UUID: LaymanContent] {
        try await laymanService.fetchBatchLaymanContent(articles: articles)
    }
}
