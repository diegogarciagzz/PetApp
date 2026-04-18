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
    @State private var postConComentarios: FeedPost?
    @State private var mostrarAmigos = false

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
                                    PostCardView(
                                        post: post,
                                        isLiked: vm.estaLike(post),
                                        totalLikes: vm.totalLikes(post),
                                        totalComentarios: vm.totalComentarios(post),
                                        onLike: { Task { await vm.toggleLike(post) } },
                                        onComentar: { postConComentarios = post }
                                    )
                                }
                            }
                        }
                    }
                    .padding(AppSpacing.screenPadding)
                }
            }
            .navigationBarHidden(true)
            .task {
                if !UserSession.shared.isLoaded { await UserSession.shared.refresh() }
                await vm.cargarFeed()
            }
            .refreshable { await vm.cargarFeed() }
            .sheet(item: $postConComentarios) { post in
                ComentariosView(post: post) {
                    vm.incrementarContadorComentarios(post)
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $mostrarAmigos) {
                AmigosView()
                    .presentationDetents([.large])
            }
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

            // Botón amigos / solicitudes
            Button {
                mostrarAmigos = true
            } label: {
                Image(systemName: "person.2.fill")
                    .font(.title3)
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(10)
                    .background(AppColors.card)
                    .clipShape(Circle())
            }
            .accessibilityLabel("Amigos")

            // Botón nueva publicación
            Button {
                vm.mostrarNuevaPublicacion = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(AppColors.primary)
            }
            .accessibilityLabel("Nueva publicación")
        }
        .sheet(isPresented: $vm.mostrarNuevaPublicacion) {
            NuevaPublicacionView()
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
    let isLiked: Bool
    let totalLikes: Int
    let totalComentarios: Int
    let onLike: () -> Void
    let onComentar: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header
            HStack(spacing: 12) {
                RemoteOrDataImage(
                    urlString: post.fotoMascota,
                    placeholderSystem: "pawprint.fill",
                    cornerRadius: 21,
                    height: 42
                )
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
            if let imagen = post.imagen, !imagen.isEmpty {
                RemoteOrDataImage(
                    urlString: imagen,
                    placeholderSystem: "photo",
                    cornerRadius: 18,
                    height: 220
                )
            }

            // Texto
            if let texto = post.texto {
                Text(texto)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textPrimary)
            }

            // Footer (acciones)
            HStack(spacing: 18) {
                Button(action: onLike) {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundStyle(isLiked ? .red : AppColors.textSecondary)
                            .scaleEffect(isLiked ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLiked)
                        Text("\(totalLikes)")
                            .foregroundStyle(AppColors.textPrimary)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isLiked ? "Quitar me gusta" : "Dar me gusta")

                Button(action: onComentar) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .foregroundStyle(AppColors.primary)
                        Text("\(totalComentarios)")
                            .foregroundStyle(AppColors.textPrimary)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Ver comentarios")

                Spacer()

                Button(action: onComentar) {
                    Text("Ver más")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.primary)
                }
                .buttonStyle(.plain)
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
