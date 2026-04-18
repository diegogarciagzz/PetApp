//
//  HomeView.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = FeedViewModel()
    @State private var selectedTab = 0

    private var currentPosts: [FeedPost] {
        selectedTab == 0 ? vm.postsForyou : vm.postsAmigos
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        segmentedControl

                        if vm.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                        } else if currentPosts.isEmpty {
                            ContentUnavailableView(
                                selectedTab == 0 ? "Sin publicaciones" : "Sin amigos aún",
                                systemImage: selectedTab == 0 ? "pawprint.fill" : "person.2.fill",
                                description: Text(selectedTab == 0
                                    ? "Aún no hay publicaciones."
                                    : "Tus amigos no han publicado nada todavía.")
                            )
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(currentPosts) { post in
                                    PostCardView(post: post)
                                }
                            }
                        }
                    }
                    .padding(AppSpacing.screenPadding)
                }
            }
            .navigationBarHidden(true)
            .task { await vm.cargarFeed() }
            .refreshable { await vm.cargarFeed() }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hola 👋")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                Text("Descubre mascotas")
                    .font(.title2.bold())
                    .foregroundStyle(AppColors.textPrimary)
            }
            Spacer()
            Image(systemName: "bell")
                .font(.title3)
                .foregroundStyle(AppColors.textPrimary)
                .padding(10)
                .background(AppColors.card)
                .clipShape(Circle())
        }
    }

    private var segmentedControl: some View {
        HStack(spacing: 10) {
            segmentButton(title: "Para ti", index: 0)
            segmentButton(title: "Siguiendo", index: 1)
        }
    }

    private func segmentButton(title: String, index: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(selectedTab == index ? .white : AppColors.textPrimary)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(selectedTab == index ? AppColors.primary : AppColors.card)
                .clipShape(Capsule())
        }
    }
}

struct PostCardView: View {
    let post: FeedPost

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: post.fotoMascota ?? "")) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
                        Circle()
                            .fill(AppColors.softBeige)
                            .overlay(
                                Image(systemName: "pawprint.fill")
                                    .foregroundStyle(AppColors.primary)
                            )
                    }
                }
                .frame(width: 42, height: 42)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.nombreMascota)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    if let raza = post.raza {
                        Text(raza)
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                Spacer()

                Text(post.fechaPublicacion.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
            }

            // Título
            if let titulo = post.titulo {
                Text(titulo)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
            }

            // Imagen
            if let imagen = post.imagen, let url = URL(string: imagen) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    case .failure:
                        RoundedRectangle(cornerRadius: 18)
                            .fill(AppColors.softBeige.opacity(0.7))
                            .frame(height: 220)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundStyle(AppColors.primary)
                            )
                    default:
                        RoundedRectangle(cornerRadius: 18)
                            .fill(AppColors.softBeige.opacity(0.7))
                            .frame(height: 220)
                            .overlay(ProgressView())
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }

            // Texto
            if let texto = post.texto {
                Text(texto)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textPrimary)
            }

            // Footer
            HStack(spacing: 18) {
                Label("\(post.totalReacciones)", systemImage: "heart.fill")
                    .foregroundStyle(.red.opacity(0.8))
                Label("\(post.totalComentarios)", systemImage: "bubble.left.fill")
                    .foregroundStyle(AppColors.primary)
                Spacer()
                Text("Ver más")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.primary)
            }
            .font(.caption.weight(.medium))
        }
        .padding(14)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardCorner))
    }
}

#Preview {
    HomeView()
}
