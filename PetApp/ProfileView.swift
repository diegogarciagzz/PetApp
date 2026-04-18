//
//  ProfileView.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import SwiftUI

struct ProfileView: View {
    let user = MockData.user

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // MARK: - Avatar + nombre
                        VStack(spacing: 12) {
                            Circle()
                                .fill(AppColors.softBeige)
                                .frame(width: 90, height: 90)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 36))
                                        .foregroundStyle(AppColors.primary)
                                )
                                .accessibilityLabel("Foto de perfil de \(user.name)")

                            Text(user.name)
                                .font(.title3.bold())
                                .foregroundStyle(AppColors.textPrimary)

                            Text(user.username)
                                .font(.subheadline)
                                .foregroundStyle(AppColors.textSecondary)
                        }

                        // MARK: - Stats
                        HStack(spacing: 12) {
                            StatCard(title: "Mascotas", value: "\(user.petsCount)")
                            StatCard(title: "Posts", value: "\(user.postsCount)")
                            StatCard(title: "Reportes", value: "\(user.reportsCount)")
                        }

                        // MARK: - Mis mascotas ✅ AGREGADO AQUÍ
                        petsSection

                        // MARK: - Opciones de perfil
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

    // MARK: - Sección de mascotas
    private var petsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mis mascotas")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(MockData.pets) { pet in
                    VStack(spacing: 8) {
                        Text(pet.emoji)
                            .font(.system(size: 40))
                            .accessibilityHidden(true)

                        Text(pet.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppColors.textPrimary)

                        Text(pet.breed)
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)

                        Text(pet.age)
                            .font(.caption2)
                            .foregroundStyle(AppColors.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(AppColors.softBeige.opacity(0.7))
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Mascota: \(pet.name), \(pet.breed), \(pet.age)")
                }
            }
        }
    }

    // MARK: - Opción de menú
    private func profileOption(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(AppColors.primary)
                .accessibilityHidden(true)

            Text(title)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(AppColors.textSecondary)
                .accessibilityHidden(true)
        }
        .padding()
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .accessibilityLabel(title)
    }
}

// MARK: - StatCard
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

#Preview {
    ProfileView()
}
