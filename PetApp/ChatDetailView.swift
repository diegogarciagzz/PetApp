//
//  ChatDetailView.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//


import SwiftUI

struct ChatDetailView: View {
    let chat: ChatPreview
    @State private var messageText = ""
    @State private var messages: [ChatMessage]

    // Sugerencias IA — esto es lo que vendes como feature de IA
    private let aiSuggestions = [
        "¿Dónde lo viste exactamente?",
        "¿Tenía collar?",
        "¿A qué hora fue?",
        "¿Puedes mandar foto?"
    ]

    init(chat: ChatPreview) {
        self.chat = chat
        _messages = State(initialValue: MockData.messages[chat.name] ?? [])
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Mensajes
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .onChange(of: messages.count) { _ in
                        if let last = messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // Sugerencias IA
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundStyle(AppColors.primary)
                            .accessibilityHidden(true)

                        ForEach(aiSuggestions, id: \.self) { suggestion in
                            Button {
                                messageText = suggestion
                            } label: {
                                Text(suggestion)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(AppColors.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(AppColors.softBeige.opacity(0.8))
                                    .clipShape(Capsule())
                            }
                            .accessibilityLabel("Sugerencia: \(suggestion)")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .background(AppColors.card)

                // Input
                HStack(spacing: 10) {
                    TextField("Escribe un mensaje...", text: $messageText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(AppColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .accessibilityLabel("Campo de mensaje")

                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(messageText.isEmpty ? Color.gray.opacity(0.4) : AppColors.primary)
                            .clipShape(Circle())
                    }
                    .disabled(messageText.isEmpty)
                    .accessibilityLabel("Enviar mensaje")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(AppColors.background)
            }
        }
        .navigationTitle(chat.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newMessage = ChatMessage(
            text: messageText,
            isFromMe: true,
            time: "Ahora"
        )
        messages.append(newMessage)
        messageText = ""
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromMe { Spacer(minLength: 60) }

            VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.subheadline)
                    .foregroundStyle(message.isFromMe ? .white : AppColors.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(message.isFromMe ? AppColors.primary : AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                Text(message.time)
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(message.isFromMe ? "Tú" : "Contacto"): \(message.text), \(message.time)")

            if !message.isFromMe { Spacer(minLength: 60) }
        }
    }
}

#Preview {
    NavigationStack {
        ChatDetailView(chat: MockData.chats[0])
    }
}