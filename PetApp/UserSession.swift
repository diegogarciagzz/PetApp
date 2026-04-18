//
//  UserSession.swift
//  PetApp
//
//  Fuente única de verdad para el usuario y la mascota activa.
//

import Foundation
import SwiftUI
import Supabase

@Observable
final class UserSession {
    static let shared = UserSession()

    var currentUser: UsuarioDB?
    var myPets: [MascotaDB] = []
    var activePetId: UUID?

    var isLoaded = false
    var lastError: String?

    private let client = SupabaseManager.shared.client

    var currentUserId: UUID? {
        client.auth.currentUser?.id ?? currentUser?.id
    }

    var activePet: MascotaDB? {
        guard let id = activePetId else { return myPets.first }
        return myPets.first(where: { $0.id == id }) ?? myPets.first
    }

    /// Carga perfil + mascotas del usuario autenticado.
    func refresh() async {
        guard let uid = client.auth.currentUser?.id else {
            currentUser = nil
            myPets = []
            activePetId = nil
            isLoaded = true
            return
        }

        do {
            let user: UsuarioDB = try await client
                .from("usuario")
                .select()
                .eq("id_usuario", value: uid)
                .single()
                .execute()
                .value
            self.currentUser = user
        } catch {
            self.lastError = "No se pudo cargar el perfil: \(error.localizedDescription)"
        }

        do {
            let pets: [MascotaDB] = try await client
                .from("mascota")
                .select()
                .eq("id_usuario", value: uid)
                .order("fecha_registro", ascending: true)
                .execute()
                .value
            self.myPets = pets
            if activePetId == nil || !pets.contains(where: { $0.id == activePetId }) {
                activePetId = pets.first?.id
            }
        } catch {
            self.lastError = "No se pudieron cargar las mascotas: \(error.localizedDescription)"
        }

        isLoaded = true
    }

    func setActivePet(_ id: UUID) {
        activePetId = id
    }

    func clear() {
        currentUser = nil
        myPets = []
        activePetId = nil
        isLoaded = false
    }
}
