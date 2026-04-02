//
//  ChatViewModel.swift
//  Layman
//
//  Created by Codex on 02/04/26.
//

import Foundation
import Combine

final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = [
        ChatMessage(text: "Hi, I'm Layman!\nWhat can I answer for you?", isUser: false)
    ]
    @Published var inputText = ""
    @Published var isTyping = false
    @Published var suggestions: [String] = []
    @Published var suggestionsLoaded = false

    private let articleContext: String
    private let chatService: LaymanChatServicing

    init(
        articleContext: String,
        chatService: LaymanChatServicing = LaymanChatService()
    ) {
        self.articleContext = articleContext
        self.chatService = chatService
    }

    func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        inputText = ""
        messages.append(ChatMessage(text: trimmed, isUser: true))
        isTyping = true

        Task {
            await fetchResponse(for: trimmed)
        }
    }

    func loadSuggestionsIfNeeded() {
        guard !suggestionsLoaded else { return }

        Task {
            do {
                suggestions = try await chatService.loadSuggestions(for: articleContext)
            } catch {
                suggestions = []
            }
            suggestionsLoaded = true
        }
    }

    private func fetchResponse(for question: String) async {
        defer { isTyping = false }

        do {
            let response = try await chatService.fetchResponse(for: question, articleContext: articleContext)
            messages.append(ChatMessage(text: response, isUser: false))
        } catch {
            messages.append(ChatMessage(text: "I couldn't answer that right now. Please try again.", isUser: false))
        }
    }
}

protocol LaymanChatServicing {
    func fetchResponse(for question: String, articleContext: String) async throws -> String
    func loadSuggestions(for articleContext: String) async throws -> [String]
}

struct LaymanChatService: LaymanChatServicing {
    private let apiKey = ProcessInfo.processInfo.environment["Layman_API_Key"] ?? ""
    private let endpoint = URL(string: "https://api.groq.com/openai/v1/chat/completions")!

    func fetchResponse(for question: String, articleContext: String) async throws -> String {
        let prompt = """
        You are Layman, a friendly AI assistant that explains news articles in plain English. \
        Your responses must be exactly 1 to 2 sentences, simple and conversational. \
        Never use jargon. The article context is: \(articleContext). \
        User question: \(question). Do NOT use markdown or bullet points.
        """

        return try await performRequest(prompt: prompt, maxTokens: 150)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func loadSuggestions(for articleContext: String) async throws -> [String] {
        let prompt = """
        You are Layman. Given this article context: \(articleContext), \
        generate exactly 3 short question suggestions a curious reader might ask. \
        Return ONLY a JSON array of 3 strings, nothing else. Example: ["Q1?","Q2?","Q3?"]
        """

        let response = try await performRequest(prompt: prompt, maxTokens: 200)
        guard
            let jsonData = response.data(using: .utf8),
            let suggestions = try? JSONDecoder().decode([String].self, from: jsonData)
        else {
            return []
        }
        return suggestions
    }

    private func performRequest(prompt: String, maxTokens: Int) async throws -> String {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "model": "llama-3.1-8b-instant",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": maxTokens,
            "temperature": 0.3
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let payload = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = payload?["choices"] as? [[String: Any]]
        let message = choices?.first?["message"] as? [String: Any]

        guard let content = message?["content"] as? String else {
            throw ChatServiceError.invalidResponse
        }

        return content
    }
}

enum ChatServiceError: Error {
    case invalidResponse
}
