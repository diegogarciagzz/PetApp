import SwiftUI

struct ProfileView: View {
    let user = MockData.user

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 12) {
                            Circle()
                                .fill(AppColors.softBeige)
                                .frame(width: 90, height: 90)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 36))
                                        .foregroundStyle(AppColors.primary)
                                )

                            Text(user.name)
                                .font(.title3.bold())
                                .foregroundStyle(AppColors.textPrimary)

                            Text(user.username)
                                .font(.subheadline)
                                .foregroundStyle(AppColors.textSecondary)
                        }

                        HStack(spacing: 12) {
                            StatCard(title: "Mascotas", value: "\(user.petsCount)")
                            StatCard(title: "Posts", value: "\(user.postsCount)")
                            StatCard(title: "Reportes", value: "\(user.reportsCount)")
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            profileOption(title: "Mis mascotas", icon: "pawprint.fill")
                            profileOption(title: "Mis publicaciones", icon: "photo.on.rectangle")
                            profileOption(title: "Mis reportes", icon: "exclamationmark.bubble.fill")
                            profileOption(title: "Configuración", icon: "gearshape.fill")
                        }
                    }
                    .padding(AppSpacing.screenPadding)
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func profileOption(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(AppColors.primary)

            Text(title)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding()
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(AppColors.textPrimary)

            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    ProfileView()
}