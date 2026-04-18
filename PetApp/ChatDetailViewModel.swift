//
//  ChatDetailViewModel.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import SwiftUI
import Combine
import Supabase

@MainActor
class ChatDetailViewModel: ObservableObject {
    @Published var mensajes: [Mensaje] = []
    @Published var isLoading = false
    @Published var isSending = false

    let idConversacion: UUID
    let idUsuarioActual: UUID

    init(idConversacion: UUID, idUsuarioActual: UUID) {
        self.idConversacion = idConversacion
        self.idUsuarioActual = idUsuarioActual
    }

    func cargarMensajes() async {
        isLoading = mensajes.isEmpty
        defer { isLoading = false }
        do {
            let result: [Mensaje] = try await SupabaseManager.shared.client
                .from("mensaje")
                .select()
                .eq("id_conversacion", value: idConversacion.uuidString)
                .order("fecha_envio", ascending: true)
                .execute()
                .value
            mensajes = result
            await marcarComoLeidos()
        } catch {
            print("Error mensajes: \(error)")
        }
    }

    func enviarTexto(_ texto: String) async {
        isSending = true
        defer { isSending = false }
        struct NuevoMensaje: Encodable {
            let id_conversacion: String
            let id_usuario_emisor: String
            let contenido: String
        }
        do {
            try await SupabaseManager.shared.client
                .from("mensaje")
                .insert(NuevoMensaje(
                    id_conversacion: idConversacion.uuidString,
                    id_usuario_emisor: idUsuarioActual.uuidString,
                    contenido: texto
                ))
                .execute()
            await cargarMensajes()
        } catch {
            print("Error enviando texto: \(error)")
        }
    }

    func enviarImagen(_ image: UIImage) async {
        guard let data = image.jpegData(compressionQuality: 0.7) else { return }
        isSending = true
        defer { isSending = false }
        let path = "mensajes-img/\(idConversacion.uuidString)/\(UUID().uuidString).jpg"
        do {
            try await SupabaseManager.shared.client.storage
                .from("mensajes-img")
                .upload(path, data: data, options: .init(contentType: "image/jpeg", upsert: false))
            let url = try SupabaseManager.shared.client.storage
                .from("mensajes-img")
                .getPublicURL(path: path)
            struct NuevoMensajeImg: Encodable {
                let id_conversacion: String
                let id_usuario_emisor: String
                let imagen_url: String
            }
            try await SupabaseManager.shared.client
                .from("mensaje")
                .insert(NuevoMensajeImg(
                    id_conversacion: idConversacion.uuidString,
                    id_usuario_emisor: idUsuarioActual.uuidString,
                    imagen_url: url.absoluteString
                ))
                .execute()
            await cargarMensajes()
        } catch {
            print("Error enviando imagen: \(error)")
        }
    }

    private func marcarComoLeidos() async {
        do {
            try await SupabaseManager.shared.client
                .from("mensaje")
                .update(["leido": true])
                .eq("id_conversacion", value: idConversacion.uuidString)
                .eq("leido", value: false)
                .neq("id_usuario_emisor", value: idUsuarioActual.uuidString)
                .execute()
        } catch {
            print("Error marcando leídos: \(error)")
        }
    }
}
