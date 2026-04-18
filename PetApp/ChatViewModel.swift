//
//  ChatViewModel.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import SwiftUI
import Combine
import Supabase

@MainActor
class ChatsViewModel: ObservableObject {
    @Published var conversaciones: [ConversacionPreview] = []
    @Published var isLoading = false

    func cargarConversaciones() async {
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id.uuidString else { return }
        isLoading = conversaciones.isEmpty
        defer { isLoading = false }
        do {
            let todas: [ConversacionPreview] = try await SupabaseManager.shared.client
                .from("vista_conversaciones")
                .select()
                .eq("id_usuario", value: userId) // filtra por el usuario autenticado en la vista
                .order("fecha_ultimo_mensaje", ascending: false)
                .execute()
                .value
            conversaciones = todas
        } catch {
            print("Error cargando conversaciones: \(error)")
        }
    }
}
