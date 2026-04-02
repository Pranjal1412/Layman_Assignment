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
    @StateObject private var viewModel: ChatViewModel
    @FocusState private var inputFocused: Bool
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isRecordingUI = false
    private let haptic = UIImpactFeedbackGenerator(style: .medium)

    init(articleContext: String) {
        self.articleContext = articleContext
        _viewModel = StateObject(wrappedValue: ChatViewModel(articleContext: articleContext))
    }

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
                            
                            ForEach(viewModel.messages) { msg in
                                ChatBubbleView(
                                    message: msg,
                                    brandOrange: brandOrange,
                                    bubbleBg: assistantBubbleBackground,
                                    userBubbleBg: userBubbleBackground
                                )
                                .id(msg.id)
                            }
                            
                            if viewModel.isTyping {
                                TypingIndicatorView(
                                    brandOrange: Color.accent,
                                    bubbleBg: assistantBubbleBackground
                                )
                            }
                            
                            if !viewModel.suggestions.isEmpty && viewModel.messages.count == 1 {
                                SuggestionsView(
                                    suggestions: viewModel.suggestions,
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
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let last = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // MARK: - Input Bar
                
                HStack(spacing: 10) {
                    
                    TextField("Type your question...", text: $viewModel.inputText)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .focused($inputFocused)
                        .submitLabel(.send)
                        .onSubmit { sendMessage(viewModel.inputText) }
                    
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
                        sendMessage(viewModel.inputText)
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 15))
                            .frame(width: 36, height: 36)
                            .background(
                                viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty
                                ? Color.accent.opacity(0.4)
                                : Color.accent
                            )
                            .clipShape(Circle())
                    }
                    .disabled(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty)
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
                viewModel.inputText = newValue
            }
            .onAppear {
                haptic.prepare()
                viewModel.loadSuggestionsIfNeeded()
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
        speechRecognizer.transcript = ""
        inputFocused = false
        withAnimation(.easeInOut(duration: 0.2)) {
            viewModel.sendMessage(text)
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
                        .frame(maxWidth: .infinity, alignment: .center)
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
