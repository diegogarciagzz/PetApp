//
//  ChatsView.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import SwiftUI

struct ChatsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(MockData.chats) { chat in
                            NavigationLink(destination: ChatDetailView(chat: chat)) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(AppColors.softBeige)
                                        .frame(width: 48, height: 48)
                                        .overlay(
                                            Text(String(chat.name.prefix(1)))
                                                .font(.headline.bold())
                                                .foregroundStyle(AppColors.primary)
                                        )
                                        .accessibilityHidden(true)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(chat.name)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(AppColors.textPrimary)

                                        Text(chat.lastMessage)
                                            .font(.caption)
                                            .foregroundStyle(AppColors.textSecondary)
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    Text(chat.time)
                                        .font(.caption2)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                                .padding()
                                .background(AppColors.card)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                            }
                            .accessibilityLabel("Chat con \(chat.name). Último mensaje: \(chat.lastMessage)")
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(AppSpacing.screenPadding)
                }
            }
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
