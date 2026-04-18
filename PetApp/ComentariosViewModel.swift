//
//  ComentariosViewModel.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import SwiftUI
import Combine
import Supabase

@MainActor
class ComentariosViewModel: ObservableObject {
    @Published var comentarios: [Comentario] = []
    @Published var isLoading = false
    @Published var isSending = false
    @Published var errorMessage: String? = nil

    let idPublicacion: UUID

    init(idPublicacion: UUID) {
        self.idPublicacion = idPublicacion
    }

    func cargarComentarios() async {
        isLoading = true
        defer { isLoading = false }
        do {
            comentarios = try await SupabaseManager.shared.client
                .from("vista_comentarios")
                .select()
                .eq("id_publicacion", value: idPublicacion.uuidString)
                .order("fecha_comentario", ascending: true)
                .execute()
                .value
        } catch {
            errorMessage = "No se pudieron cargar los comentarios."
            print("Error comentarios: \(error)")
        }
    }

    func enviarComentario(texto: String) async {
        // Obtener la primera mascota del usuario autenticado
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id.uuidString else { return }
        isSending = true
        defer { isSending = false }
        do {
            // Busca la primera mascota del usuario
            struct MascotaID: Decodable { let id_mascota: UUID }
            let mascotas: [MascotaID] = try await SupabaseManager.shared.client
                .from("mascota")
                .select("id_mascota")
                .eq("id_usuario", value: userId)
                .limit(1)
                .execute()
                .value
            guard let mascota = mascotas.first else {
                errorMessage = "Necesitas tener una mascota para comentar."
                return
            }
            struct NuevoComentario: Encodable {
                let id_publicacion: String
                let id_mascota: String
                let texto: String
            }
            try await SupabaseManager.shared.client
                .from("comentario")
                .insert(NuevoComentario(
                    id_publicacion: idPublicacion.uuidString,
                    id_mascota: mascota.id_mascota.uuidString,
                    texto: texto
                ))
                .execute()
            await cargarComentarios()
        } catch {
            errorMessage = "No se pudo enviar el comentario."
            print("Error enviando comentario: \(error)")
        }
    }
}
