//
//  FeedViewModel.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import Foundation
import Combine
import Supabase

@MainActor
class FeedViewModel: ObservableObject {
    @Published var postsForyou: [FeedPost] = []
    @Published var postsAmigos: [FeedPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var mostrarNuevaPublicacion = false

    /// Posts a los que la mascota actual ya dio like.
    @Published var likedPostIds: Set<UUID> = []
    /// Overrides locales para contadores (optimistic updates).
    @Published var likeOverrides: [UUID: Int] = [:]
    @Published var comentariosOverrides: [UUID: Int] = [:]

    private let client = SupabaseManager.shared.client

    /// id de la mascota activa del usuario logueado.
    var idMascotaActual: UUID? {
        UserSession.shared.activePetId
    }

    // MARK: - Cargar feed
    func cargarFeed() async {
        if postsForyou.isEmpty && postsAmigos.isEmpty {
            isLoading = true
        }
        errorMessage = nil

        async let foryou: [FeedPost] = cargarForYou()
        async let amigos: [FeedPost] = cargarAmigos()

        postsForyou = (try? await foryou) ?? postsForyou
        postsAmigos = (try? await amigos) ?? postsAmigos

        if let mascota = idMascotaActual {
            if let likes = try? await SocialService.shared.reaccionesDe(mascota: mascota) {
                likedPostIds = likes
            }
        }

        isLoading = false
    }

    private func cargarForYou() async throws -> [FeedPost] {
        try await client
            .from("vista_feed_foryou")
            .select()
            .order("fecha_publicacion", ascending: false)
            .execute()
            .value
    }

    private func cargarAmigos() async throws -> [FeedPost] {
        guard let mascota = idMascotaActual else { return [] }
        let idStr = mascota.uuidString.lowercased()
        let todos: [FeedPostAmigos] = try await client
            .from("vista_feed_amigos")
            .select()
            .execute()
            .value
        return todos
            .filter { $0.espectador1.uuidString.lowercased() == idStr ||
                      $0.espectador2.uuidString.lowercased() == idStr }
            .map { $0.toFeedPost() }
    }

    // MARK: - Likes
    func estaLike(_ post: FeedPost) -> Bool {
        likedPostIds.contains(post.id)
    }

    func totalLikes(_ post: FeedPost) -> Int {
        likeOverrides[post.id] ?? post.totalReacciones
    }

    func totalComentarios(_ post: FeedPost) -> Int {
        comentariosOverrides[post.id] ?? post.totalComentarios
    }

    func toggleLike(_ post: FeedPost) async {
        guard let mascota = idMascotaActual else {
            errorMessage = "Necesitas una mascota para reaccionar."
            return
        }
        // Optimistic update
        let estaba = estaLike(post)
        if estaba {
            likedPostIds.remove(post.id)
            likeOverrides[post.id] = totalLikes(post) - 1
        } else {
            likedPostIds.insert(post.id)
            likeOverrides[post.id] = totalLikes(post) + 1
        }

        do {
            let quedaActivo = try await SocialService.shared.toggleLike(
                publicacion: post.id,
                mascota: mascota
            )
            if quedaActivo {
                likedPostIds.insert(post.id)
            } else {
                likedPostIds.remove(post.id)
            }
        } catch {
            // Revertir
            if estaba {
                likedPostIds.insert(post.id)
                likeOverrides[post.id] = totalLikes(post) + 1
            } else {
                likedPostIds.remove(post.id)
                likeOverrides[post.id] = max(0, totalLikes(post) - 1)
            }
            errorMessage = "No se pudo actualizar la reacción: \(error.localizedDescription)"
        }
    }

    func incrementarContadorComentarios(_ post: FeedPost) {
        comentariosOverrides[post.id] = totalComentarios(post) + 1
    }
}
