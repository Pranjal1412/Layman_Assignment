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

struct LaymanTransformService {
    private let apiKey = ProcessInfo.processInfo.environment["Layman_API_Key"] ?? ""
    private let endpoint = URL(string: "https://api.groq.com/openai/v1/chat/completions")!

    func fetchLaymanContent(title: String, description: String?) async throws -> LaymanContent {
        let prompt = """
        Rewrite the following news into simple, casual, easy-to-understand language.

        STRICT RULES:

        HEADLINE:
        - 7–9 words
        - 48–52 characters max
        - Conversational tone (like explaining to a friend)
        - No formal news language

        CONTENT CARDS:
        - Exactly 3 cards
        - Each card = exactly 2 sentences
        - Each card = 28–35 words
        - Keep sentences short and clear
        - Each card should represent a different part of the story
        - No jargon, no complex terms

        RETURN FORMAT (STRICT JSON ONLY, no markdown, no backticks):
        {
          "headline": "...",
          "cards": ["...", "...", "..."]
        }

        INPUT:
        Headline: "\(title)"
        Description: "\(description ?? "")"
        """

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "model": "llama-3.1-8b-instant",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 500,
            "temperature": 0.3
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        guard
            let payload = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = payload["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any],
            let content = message["content"] as? String
        else {
            throw URLError(.badServerResponse)
        }

        // Strip any accidental markdown fences
        let clean = content
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = clean.data(using: .utf8) else {
            throw URLError(.cannotParseResponse)
        }

        return try JSONDecoder().decode(LaymanContent.self, from: jsonData)
    }
}
