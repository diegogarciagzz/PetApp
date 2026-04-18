//
//  AmistadViewModel.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import SwiftUI
import Combine
import Supabase

@MainActor
class AmistadViewModel: ObservableObject {
    @Published var amigos: [Amistad] = []
    @Published var solicitudesRecibidas: [Amistad] = []
    @Published var isLoading = false

    private let idMascota: UUID

    init(idMascota: UUID) {
        self.idMascota = idMascota
    }

    func cargar() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let todas: [Amistad] = try await SupabaseManager.shared.client
                .from("vista_amigos")
                .select()
                .or("id_solicitante.eq.\(idMascota),id_receptor.eq.\(idMascota)")
                .execute()
                .value

            amigos = todas.filter { $0.estado == .aceptado }
            solicitudesRecibidas = todas.filter {
                $0.estado == .pendiente && $0.idReceptor == idMascota
            }
        } catch {
            print("❌ Error cargando amistades: \(error)")
        }
    }

    func aceptar(_ amistad: Amistad) async {
        await cambiarEstado(amistad, nuevoEstado: "aceptado")
    }

    func rechazar(_ amistad: Amistad) async {
        await cambiarEstado(amistad, nuevoEstado: "rechazado")
    }

    func eliminar(_ amistad: Amistad) async {
        do {
            try await SupabaseManager.shared.client
                .from("amistad_mascota")
                .delete()
                .eq("id_amistad", value: amistad.id.uuidString)
                .execute()
            await cargar()
        } catch {
            print("❌ Error eliminando amistad: \(error)")
        }
    }

    private func cambiarEstado(_ amistad: Amistad, nuevoEstado: String) async {
        struct Patch: Encodable {
            let estado: String
            let fecha_respuesta: String
        }
        do {
            try await SupabaseManager.shared.client
                .from("amistad_mascota")
                .update(Patch(
                    estado: nuevoEstado,
                    fecha_respuesta: ISO8601DateFormatter().string(from: Date())
                ))
                .eq("id_amistad", value: amistad.id.uuidString)
                .execute()
            await cargar()
        } catch {
            print("❌ Error actualizando estado: \(error)")
        }
    }
}
