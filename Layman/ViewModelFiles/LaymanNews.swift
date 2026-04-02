//
//  LaymanNews.swift
//  Layman
//
//  Created by Pranjal   on 02/04/26.
//

import Foundation

struct LaymanContent: Codable {
    let headline: String
    let cards: [String]
}

// ✅ Batch Response Models
struct BatchLaymanResponse: Codable {
    let results: [BatchItem]
}

struct BatchItem: Codable {
    let id: String
    let headline: String
    let cards: [String]
}

struct LaymanTransformService {
    
    private let apiKey = ProcessInfo.processInfo.environment["Layman_API_Key"] ?? ""
    private let endpoint = URL(string: "https://api.groq.com/openai/v1/chat/completions")!
    
    // MARK: - ✅ SINGLE ARTICLE (unchanged)
    func fetchLaymanContent(title: String, description: String?) async throws -> LaymanContent {
        
        let prompt = """
        Rewrite the following news into simple, casual, easy-to-understand language.

        STRICT RULES:

        HEADLINE:
        - 7–9 words
        - 48–52 characters max
        - Conversational tone
        - No formal news language

        CONTENT CARDS:
        - Exactly 3 cards
        - Each card = exactly 2 sentences
        - Each card = 28–35 words
        - No jargon

        RETURN JSON:
        {
          "headline": "...",
          "cards": ["...", "...", "..."]
        }

        INPUT:
        Headline: "\(title)"
        Description: "\(description ?? "")"
        """

        return try await performRequest(prompt: prompt)
            .decodeSingle()
    }
    
    // MARK: - ✅ BATCH (NEW)
    func fetchBatchLaymanContent(articles: [NewsArticle]) async throws -> [String: LaymanContent] {
        guard !articles.isEmpty else { return [:] }
        
        let formattedInput = articles.map {
            """
            ID: \($0.id)
            Title: \($0.title)
            Description: \($0.description ?? "")
            """
        }.joined(separator: "\n\n")

        let prompt = """
        Convert the following news articles into simple language.
        
        Rewrite the following news into simple, casual, easy-to-understand language.

        STRICT RULES
        HEADLINE:
        - 7–9 words
        - 48–52 characters max
        - Conversational tone
        - No formal news language

        CONTENT CARDS:
        - Exactly 3 cards
        - Each card = exactly 2 sentences
        - Each card = 28–35 words
        - No jargon

        RETURN STRICT JSON:
        {
          "results": [
            {
              "id": "...",
              "headline": "...",
              "cards": ["...", "...", "..."]
            }
          ]
        }

        ARTICLES:
        \(formattedInput)
        """

        let content = try await performRequest(prompt: prompt)
        print("RAW LLM OUTPUT:\n", content)
        let decoded = try content.decodeBatch()
        
        var result: [String: LaymanContent] = [:]
        
        for item in decoded.results {
            result[item.id] = LaymanContent(
                headline: item.headline,
                cards: item.cards
            )
        }
        
        return result
    }

    func fetchBatchLaymanContentInChunks(
        articles: [NewsArticle],
        chunkSize: Int = 2
    ) async throws -> [String: LaymanContent] {
        guard !articles.isEmpty else { return [:] }

        var aggregated: [String: LaymanContent] = [:]

        for chunkStart in stride(from: 0, to: articles.count, by: chunkSize) {
            let chunkEnd = min(chunkStart + chunkSize, articles.count)
            let chunk = Array(articles[chunkStart..<chunkEnd])
            let partialResult = try await fetchBatchLaymanContent(articles: chunk)

            for (id, content) in partialResult {
                aggregated[id] = content
            }
        }

        return aggregated
    }
    
    // MARK: - ✅ COMMON REQUEST HANDLER
    private func performRequest(prompt: String) async throws -> String {
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "model": "llama-3.1-8b-instant",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 800,
            "temperature": 0.3,
            "response_format": ["type": "json_object"]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse {
            print("Status Code:", http.statusCode)
            
            if http.statusCode != 200 {
                print("RAW ERROR RESPONSE:")
                print(String(data: data, encoding: .utf8) ?? "No response body")
                throw URLError(.badServerResponse)
            }
        }

        guard
            let payload = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = payload["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any],
            let content = message["content"] as? String
        else {
            throw URLError(.badServerResponse)
        }

        return content.cleanJSON()
    }
}

// MARK: - ✅ Helpers (clean + decode)
private extension String {
    
    func cleanJSON() -> String {
        let cleaned = self
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // ✅ Extract ONLY JSON part
        if let start = cleaned.firstIndex(of: "{"),
           let end = cleaned.lastIndex(of: "}") {
            return String(cleaned[start...end])
        }
        
        return cleaned
    }
    
    func decodeSingle() throws -> LaymanContent {
        guard let data = self.data(using: .utf8) else {
            throw URLError(.cannotParseResponse)
        }
        return try JSONDecoder().decode(LaymanContent.self, from: data)
    }
    
    func decodeBatch() throws -> BatchLaymanResponse {
        guard let data = self.data(using: .utf8) else {
            throw URLError(.cannotParseResponse)
        }
        return try JSONDecoder().decode(BatchLaymanResponse.self, from: data)
    }
}
