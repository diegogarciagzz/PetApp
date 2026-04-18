//
//  ReportService.swift
//  PetApp
//
//  CRUD de reportes de mascotas perdidas y avistamientos.
//

import Foundation
import Supabase

final class ReportService {
    static let shared = ReportService()
    private let client = SupabaseManager.shared.client
    private init() {}

    // MARK: - Crear reporte
    func crearReporte(
        idMascota: UUID,
        idUsuario: UUID,
        descripcion: String?,
        fotoReferencia: String?,
        latitud: Double?,
        longitud: Double?,
        ubicacionDesc: String?,
        estado: String = "activo"
    ) async throws {
        let payload = ReporteInsert(
            idMascota: idMascota,
            idUsuario: idUsuario,
            descripcion: descripcion,
            fotoReferencia: fotoReferencia,
            ultimaLatConocida: latitud,
            ultimaLonConocida: longitud,
            ultimaUbicacionDesc: ubicacionDesc,
            estado: estado
        )
        try await client
            .from("reporte_perdida")
            .insert(payload)
            .execute()
    }

    // MARK: - Mis reportes
    func reportesDe(usuario: UUID) async throws -> [MascotaPerdida] {
        try await client
            .from("vista_mascotas_perdidas")
            .select()
            .eq("id_dueno", value: usuario)
            .execute()
            .value
    }

    // MARK: - Avistamientos
    func avistamientos(reporte: UUID) async throws -> [AvistamientoDB] {
        try await client
            .from("avistamiento")
            .select()
            .eq("id_reporte", value: reporte)
            .order("fecha_avistamiento", ascending: false)
            .execute()
            .value
    }

    func agregarAvistamiento(
        idReporte: UUID,
        idUsuario: UUID,
        latitud: Double?,
        longitud: Double?,
        descripcionLugar: String?,
        notas: String?,
        fotoAvistamiento: String?
    ) async throws {
        let payload = AvistamientoInsert(
            idReporte: idReporte,
            idUsuario: idUsuario,
            latitud: latitud,
            longitud: longitud,
            descripcionLugar: descripcionLugar,
            notas: notas,
            fotoAvistamiento: fotoAvistamiento
        )
        try await client
            .from("avistamiento")
            .insert(payload)
            .execute()
    }

    // MARK: - Cerrar/marcar reporte
    func marcarResuelto(reporte: UUID) async throws {
        struct Update: Encodable {
            let estado: String
            let fechaResolucion: Date
            enum CodingKeys: String, CodingKey {
                case estado
                case fechaResolucion = "fecha_resolucion"
            }
        }
        try await client
            .from("reporte_perdida")
            .update(Update(estado: "resuelto", fechaResolucion: Date()))
            .eq("id_reporte", value: reporte)
            .execute()
    }
}
