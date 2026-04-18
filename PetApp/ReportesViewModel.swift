//
//  ReportesViewModel.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import Foundation
import Combine
import Supabase

@MainActor
class ReportesViewModel: ObservableObject {
    @Published var reportes: [MascotaPerdida]   = []
    @Published var misMascotas: [MascotaSimple] = []
    @Published var isLoading                    = false
    @Published var errorMessage: String?

    private let client = SupabaseManager.shared.client

    var userId: String? {
        client.auth.currentUser?.id.uuidString
    }

    // MARK: Cargar reportes activos
    func cargarReportes() async {
        isLoading = true
        errorMessage = nil
        do {
            reportes = try await client
                .from("vista_mascotas_perdidas")
                .select()
                .execute()
                .value
            print("✅ Reportes cargados: \(reportes.count)")
        } catch {
            print("❌ Error: \(error)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: Cargar mis mascotas para el formulario
    func cargarMisMascotas() async {
        guard let userId else { return }
        do {
            misMascotas = try await client
                .from("mascota")
                .select("id_mascota, nombre, tipo_animal, raza")
                .eq("id_usuario", value: userId)
                .execute()
                .value
        } catch {
            print("❌ Error cargando mascotas: \(error)")
        }
    }

    // MARK: Crear reporte de mascota desaparecida
    func crearReporte(
        idMascota: UUID,
        descripcion: String,
        ubicacionDesc: String,
        lat: Double,
        lon: Double
    ) async {
        guard let userId else { return }
        do {
            try await client
                .from("reporte_perdida")
                .insert([
                    "id_mascota":            idMascota.uuidString,
                    "id_usuario":            userId,
                    "descripcion":           descripcion,
                    "ultima_ubicacion_desc": ubicacionDesc,
                    "ultima_lat_conocida":   String(lat),
                    "ultima_lon_conocida":   String(lon),
                    "estado":                "activo"
                ])
                .execute()
            await cargarReportes()
            print("✅ Reporte creado")
        } catch {
            print("❌ Error creando reporte: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Marcar mascota como encontrada (solo el dueño)
    func marcarEncontrada(reporte: MascotaPerdida) async {
        do {
            try await client
                .from("reporte_perdida")
                .update([
                    "estado":           "resuelto",
                    "fecha_resolucion": ISO8601DateFormatter().string(from: Date())
                ])
                .eq("id_reporte", value: reporte.id.uuidString)
                .execute()
            await cargarReportes()
            print("✅ Mascota marcada como encontrada")
        } catch {
            print("❌ Error: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Reportar avistamiento con pin en el mapa
    func reportarAvistamiento(
        idReporte: UUID,
        lat: Double,
        lon: Double,
        descripcion: String
    ) async {
        guard let userId else { return }
        do {
            try await client
                .from("avistamiento")
                .insert([
                    "id_reporte":  idReporte.uuidString,
                    "id_usuario":  userId,
                    "latitud":     String(lat),
                    "longitud":    String(lon),
                    "descripcion": descripcion
                ])
                .execute()
            await cargarReportes()
            print("✅ Avistamiento reportado")
        } catch {
            print("❌ Error avistamiento: \(error)")
            errorMessage = error.localizedDescription
        }
    }
}
