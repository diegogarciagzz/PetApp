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

    // TODO: reemplaza este UUID por el id_mascota del usuario logueado
    let idMascotaActual: UUID = UUID(uuidString: "b1000000-0000-0000-0000-000000000001")!

    private let client = SupabaseManager.shared.client

    func cargarFeed() async {
        // No borra los posts existentes, solo muestra loading si está vacío
        if postsForyou.isEmpty && postsAmigos.isEmpty {
            isLoading = true
        }
        errorMessage = nil
        async let foryou: [FeedPost] = cargarForYou()
        async let amigos: [FeedPost] = cargarAmigos()
        postsForyou = (try? await foryou) ?? postsForyou
        postsAmigos = (try? await amigos) ?? postsAmigos
        isLoading = false
    }

    private func cargarForYou() async throws -> [FeedPost] {
        try await client
            .from("vista_feed_foryou")
            .select()
            .execute()
            .value
    }

    private func cargarAmigos() async throws -> [FeedPost] {
        let idStr = idMascotaActual.uuidString.lowercased()
        let todos: [FeedPostAmigos] = try await client
            .from("vista_feed_amigos")
            .select()
            .execute()
            .value
        // filtra solo los posts donde la mascota actual es uno de los espectadores
        return todos
            .filter { $0.espectador1.uuidString.lowercased() == idStr ||
                      $0.espectador2.uuidString.lowercased() == idStr }
            .map { $0.toFeedPost() }
    }
}
