//
//  ChatView.swift
//  Layman
//
//  Created by Pranjal on 01/04/26.
//

import SwiftUI
import Combine

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct AskLaymanModalView: View {
    @Environment(\.colorScheme) private var colorScheme
    let articleContext: String
    
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hi, I'm Layman!\nWhat can I answer for you?", isUser: false)
    ]
    @State private var inputText: String = ""
    @State private var isTyping: Bool = false
    @State private var suggestions: [String] = []
    @State private var suggestionsLoaded = false
    @FocusState private var inputFocused: Bool
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    // NEW
    @State private var isRecordingUI = false
    private let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    let apiKey = ProcessInfo.processInfo.environment["Layman_API_Key"]
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    inputFocused = false
                }
            
            VStack(spacing: 0) {
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            
                            ForEach(messages) { msg in
                                ChatBubbleView(
                                    message: msg,
                                    brandOrange: brandOrange,
                                    bubbleBg: assistantBubbleBackground,
                                    userBubbleBg: userBubbleBackground
                                )
                                .id(msg.id)
                            }
                            
                            if isTyping {
                                TypingIndicatorView(
                                    brandOrange: Color.accent,
                                    bubbleBg: assistantBubbleBackground
                                )
                            }
                            
                            if !suggestions.isEmpty && messages.count == 1 {
                                SuggestionsView(
                                    suggestions: suggestions,
                                    brandOrange: brandOrange
                                ) { suggestion in
                                    sendMessage(suggestion)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 12)
                    }
                    .gesture(
                        DragGesture().onChanged { _ in
                            inputFocused = false
                        }
                    )
                    .onChange(of: messages.count) { _, _ in
                        if let last = messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // MARK: - Input Bar
                
                HStack(spacing: 10) {
                    
                    TextField("Type your question...", text: $inputText)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .focused($inputFocused)
                        .submitLabel(.send)
                        .onSubmit { sendMessage(inputText) }
                    
                    Button {
                        if speechRecognizer.isRecording {
                            speechRecognizer.stopRecording()
                            isRecordingUI = false
                            
                            if !speechRecognizer.transcript.isEmpty {
                                sendMessage(speechRecognizer.transcript)
                            }
                        } else {
                            haptic.impactOccurred()
                            
                            speechRecognizer.startRecording()
                            isRecordingUI = true
                            inputFocused = false
                        }
                    } label: {
                        Image(systemName: isRecordingUI ? "mic.fill" : "mic")
                            .foregroundColor(
                                isRecordingUI ? .red : Color(hex: "#9E8E7E")
                            )
                            .font(.system(size: 18))
                    }
                    
                    Button {
                        sendMessage(inputText)
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 15))
                            .frame(width: 36, height: 36)
                            .background(
                                inputText.trimmingCharacters(in: .whitespaces).isEmpty
                                ? Color.accent.opacity(0.4)
                                : Color.accent
                            )
                            .clipShape(Circle())
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 100)
                        .fill(inputBarBackground)
                        .shadow(color: .black.opacity(0.06), radius: 4, y: -2)
                )
                .padding(.horizontal, 16)
            }
            .onChange(of: speechRecognizer.transcript) { _, newValue in
                inputText = newValue
            }
            .onAppear {
                haptic.prepare()
                
                if !suggestionsLoaded {
                    loadSuggestions()
                }
            }
        }
        .background(Color.viewBackground)
    }

    // MARK: - Colors
    
    private var brandOrange: Color { Color.accent }
    
    private var assistantBubbleBackground: Color {
        colorScheme == .dark ? Color(red: 0.22, green: 0.18, blue: 0.15) : Color(hex: "#E4D5C1")
    }
    
    private var userBubbleBackground: Color {
        colorScheme == .dark ? Color(red: 0.18, green: 0.16, blue: 0.14) : Color(hex: "#F0E7DB")
    }
    
    private var inputBarBackground: Color {
        colorScheme == .dark ? Color(red: 0.14, green: 0.12, blue: 0.10) : Color(hex: "#EFEBE4")
    }
    
    // MARK: - Send
    
    private func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        inputText = ""
        speechRecognizer.transcript = ""
        inputFocused = false
        
        withAnimation(.easeInOut(duration: 0.2)) {
            messages.append(ChatMessage(text: trimmed, isUser: true))
            isTyping = true
        }
        
        fetchLaymanResponse(for: trimmed)
    }
    
    // MARK: - API Call
    
    private func fetchLaymanResponse(for question: String) {
        let prompt = """
        You are Layman, a friendly AI assistant that explains news articles in plain English. \
        Your responses must be exactly 1 to 2 sentences, simple and conversational. \
        Never use jargon. The article context is: \(articleContext). \
        User question: \(question). Do NOT use markdown or bullet points.
        """

        Task {
            do {
                let url = URL(string: "https://api.groq.com/openai/v1/chat/completions")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("Bearer \(apiKey ?? "")", forHTTPHeaderField: "Authorization")

                let body: [String: Any] = [
                    "model": "llama-3.1-8b-instant",
                    "messages": [["role": "user", "content": prompt]],
                    "max_tokens": 150,
                    "temperature": 0.3
                ]

                request.httpBody = try JSONSerialization.data(withJSONObject: body)

                let (data, _) = try await URLSession.shared.data(for: request)

                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    await MainActor.run {
                        withAnimation {
                            isTyping = false
                            messages.append(ChatMessage(text: content.trimmingCharacters(in: .whitespacesAndNewlines), isUser: false))
                        }
                    }
                } else {
                    await MainActor.run { isTyping = false }
                }
            } catch {
                await MainActor.run { isTyping = false }
                print("Error:", error)
            }
        }
    }

    private func loadSuggestions() {
        let prompt = """
        You are Layman. Given this article context: \(articleContext), \
        generate exactly 3 short question suggestions a curious reader might ask. \
        Return ONLY a JSON array of 3 strings, nothing else. Example: ["Q1?","Q2?","Q3?"]
        """

        Task {
            do {
                let url = URL(string: "https://api.groq.com/openai/v1/chat/completions")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("Bearer \(apiKey ?? "")", forHTTPHeaderField: "Authorization")

                let body: [String: Any] = [
                    "model": "llama-3.1-8b-instant",
                    "messages": [["role": "user", "content": prompt]],
                    "max_tokens": 200,
                    "temperature": 0.3
                ]

                request.httpBody = try JSONSerialization.data(withJSONObject: body)

                let (data, _) = try await URLSession.shared.data(for: request)

                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String,
                   let jsonData = content.data(using: .utf8),
                   let array = try? JSONDecoder().decode([String].self, from: jsonData) {
                    
                    await MainActor.run {
                        withAnimation {
                            suggestions = array
                            suggestionsLoaded = true
                        }
                    }
                } else {
                    await MainActor.run { suggestionsLoaded = true }
                }

            } catch {
                await MainActor.run { suggestionsLoaded = true }
                print("Error loading suggestions:", error)
            }
        }
    }
}
// MARK: - Chat Bubble

struct ChatBubbleView: View {
    @Environment(\.colorScheme) private var colorScheme
    let message: ChatMessage
    let brandOrange: Color
    let bubbleBg: Color
    let userBubbleBg: Color

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 40)
                Text(message.text)
                    .font(.system(size: 14))
                    .foregroundColor(messageTextColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(userBubbleBg)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                // User avatar
                ZStack {
                    Circle()
                        .fill(Color(hex: "#D0C4B8"))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.accent, lineWidth: 1.0)
                        )
                    Image(systemName: "person.fill")
                        .foregroundColor(.accent)
                        .font(.system(size: 14))
                }
            } else {
                // Layman avatar
                ZStack {
                    Circle()
                        .fill(.accent)
                        .frame(width: 30, height: 30)
                    Image(systemName: "sparkles")
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .bold))
                }
                Text(message.text)
                    .font(.system(size: 14))
                    .foregroundColor(messageTextColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(bubbleBg)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                Spacer(minLength: 40)
            }
        }
    }

    private var messageTextColor: Color {
        colorScheme == .dark ? Color.primaryText : Color(hex: "#3A2E26")
    }
}

// MARK: - Typing Indicator

struct TypingIndicatorView: View {
    @Environment(\.colorScheme) private var colorScheme
    let brandOrange: Color
    let bubbleBg: Color
    @State private var phase = 0
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            ZStack {
                Circle().fill(.accent).frame(width: 30, height: 30)
                Image(systemName: "sparkles")
                    .foregroundColor(.white)
                    .font(.system(size: 12, weight: .bold))
            }
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(typingDotColor)
                        .frame(width: 7, height: 7)
                        .scaleEffect(phase == i ? 1.4 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: phase)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(bubbleBg)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            Spacer()
        }
        .onReceive(timer) { _ in phase = (phase + 1) % 3 }
    }

    private var typingDotColor: Color {
        colorScheme == .dark ? Color.primaryText.opacity(0.65) : Color(hex: "#9E8E7E")
    }
}

// MARK: - Suggestions

struct SuggestionsView: View {
    @Environment(\.colorScheme) private var colorScheme
    let suggestions: [String]
    let brandOrange: Color
    let onTap: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Question Suggestions:")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(labelColor)
                .padding(.leading, 2)
            
            ForEach(suggestions, id: \.self) { suggestion in
                Button { onTap(suggestion) } label: {
                    Text(suggestion)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 11)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(brandOrange)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.top, 4)
    }

    private var labelColor: Color {
        colorScheme == .dark ? Color.primaryText.opacity(0.65) : Color(hex: "#9E8E7E")
    }
}

// MARK: - Color Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
