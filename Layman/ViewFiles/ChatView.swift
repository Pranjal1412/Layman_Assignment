//
//  ChatView.swift
//  Layman
//
//  Created by Pranjal   on 01/04/26.
//

import SwiftUI

struct AskLaymanView: View {
    @State private var questionText: String = ""
    
    var body: some View {
        ZStack {
            // Background Image (Blurred)
            Image("article_bg") // Replace with your asset name
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 10)
                .overlay(Color.black.opacity(0.1))
            
            VStack(spacing: 0) {
                Spacer()
                
                // Chat Container
                VStack(alignment: .leading, spacing: 16) {
                    // Pull indicator
                    Capsule()
                        .frame(width: 40, height: 4)
                        .foregroundColor(.gray.opacity(0.3))
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity)
                    
                    // Bot Initial Greeting
                    ChatBubble(message: "Hi, I'm Layman!\nWhat can I answer for you?", isBot: true)
                    
                    // Question Suggestions Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Question Suggestions:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.brown)
                        
                        SuggestionButton(text: "Where did Elon Musk go to college?")
                        SuggestionButton(text: "How much did it cost to make Grok?")
                        SuggestionButton(text: "How is this different than ChatGPT?")
                    }
                    .padding(.bottom, 20)
                    
                    // Input Area
                    HStack {
                        TextField("Type your question...", text: $questionText)
                            .padding(.leading, 12)
                        
                        Image(systemName: "mic.fill")
                            .foregroundColor(.gray)
                        
                        Button(action: {}) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.orange)
                                .clipShape(Circle())
                        }
                    }
                    .padding(8)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(25)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color(red: 0.98, green: 0.94, blue: 0.88)) // Cream background
                )
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

// MARK: - Components

struct ChatBubble: View {
    let message: String
    let isBot: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if isBot {
                Image(systemName: "sparkles")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.brown.opacity(0.7))
                    .clipShape(Circle())
            }
            
            Text(message)
                .font(.system(size: 15))
                .padding(12)
                .background(isBot ? Color.brown.opacity(0.2) : Color.white)
                .cornerRadius(12)
            
            if !isBot {
                Spacer()
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.brown.opacity(0.5))
            }
        }
    }
}

struct SuggestionButton: View {
    let text: String
    
    var body: some View {
        Button(action: {}) {
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Color.brown.opacity(0.8))
                .cornerRadius(20)
        }
    }
}

#Preview {
    AskLaymanView()
}
