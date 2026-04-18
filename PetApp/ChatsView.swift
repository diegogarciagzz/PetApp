import SwiftUI

struct ChatsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(MockData.chats) { chat in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(AppColors.softBeige)
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundStyle(AppColors.primary)
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(chat.name)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(AppColors.textPrimary)

                                    Text(chat.lastMessage)
                                        .font(.caption)
                                        .foregroundStyle(AppColors.textSecondary)
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
                    }
                    .padding(AppSpacing.screenPadding)
                }
            }
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ChatsView()
}