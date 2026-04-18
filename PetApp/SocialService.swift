//
//  SocialService.swift
//  PetApp
//
//  Reacciones, comentarios y amistades entre mascotas.
//

import Foundation
import Supabase

final class SocialService {
    static let shared = SocialService()
    private let client = SupabaseManager.shared.client
    private init() {}

    // MARK: - Tipos de reacción (cache)
    private var cachedTipos: [TipoReaccionDB] = []

    func tiposReaccion() async throws -> [TipoReaccionDB] {
        if !cachedTipos.isEmpty { return cachedTipos }
        let tipos: [TipoReaccionDB] = try await client
            .from("tipo_reaccion")
            .select()
            .eq("activo", value: true)
            .execute()
            .value
        cachedTipos = tipos
        return tipos
    }

    /// Devuelve el tipo "Me gusta" por defecto, o el primero disponible.
    func tipoLikeDefault() async throws -> TipoReaccionDB? {
        let tipos = try await tiposReaccion()
        return tipos.first(where: { $0.nombre.lowercased().contains("gusta") ||
                                   $0.nombre.lowercased().contains("like") })
            ?? tipos.first
    }

    // MARK: - Reacciones
    /// Regresa true si quedó con like activo, false si se quitó.
    @discardableResult
    func toggleLike(publicacion: UUID, mascota: UUID) async throws -> Bool {
        guard let tipo = try await tipoLikeDefault() else {
            throw NSError(domain: "SocialService", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "No hay tipos de reacción disponibles."])
        }

        let existentes: [ReaccionDB] = try await client
            .from("reaccion_publicacion")
            .select()
            .eq("id_publicacion", value: publicacion)
            .eq("id_mascota", value: mascota)
            .eq("id_tipo_reaccion", value: tipo.id)
            .execute()
            .value

        if let existente = existentes.first {
            try await client
                .from("reaccion_publicacion")
                .delete()
                .eq("id_reaccion", value: existente.id)
                .execute()
            return false
        } else {
            let insert = ReaccionInsert(
                idPublicacion: publicacion,
                idMascota: mascota,
                idTipoReaccion: tipo.id
            )
            try await client
                .from("reaccion_publicacion")
                .insert(insert)
                .execute()
            return true
        }
    }

    /// Publicaciones a las que la mascota ya dio like.
    func reaccionesDe(mascota: UUID) async throws -> Set<UUID> {
        let rows: [ReaccionDB] = try await client
            .from("reaccion_publicacion")
            .select()
            .eq("id_mascota", value: mascota)
            .execute()
            .value
        return Set(rows.map { $0.idPublicacion })
    }

    // MARK: - Comentarios
    func comentarios(publicacion: UUID) async throws -> [ComentarioConAutor] {
        // Intenta usar la vista enriquecida; si falla, usa join manual.
        if let directos: [ComentarioConAutor] = try? await client
            .from("vista_comentarios_publicacion")
            .select()
            .eq("id_publicacion", value: publicacion)
            .order("fecha_comentario", ascending: true)
            .execute()
            .value {
            return directos
        }

        // Fallback: trae comentarios crudos y enriquece con nombre de mascota.
        let base: [ComentarioDB] = try await client
            .from("comentario")
            .select()
            .eq("id_publicacion", value: publicacion)
            .order("fecha_comentario", ascending: true)
            .execute()
            .value

        let mascotaIds = Array(Set(base.map { $0.idMascota }))
        var infoPorId: [UUID: MascotaDB] = [:]
        if !mascotaIds.isEmpty {
            let mascotas: [MascotaDB] = try await client
                .from("mascota")
                .select()
                .in("id_mascota", values: mascotaIds)
                .execute()
                .value
            for m in mascotas { infoPorId[m.id] = m }
        }

        return base.map { c in
            let m = infoPorId[c.idMascota]
            return ComentarioConAutor(
                id: c.id,
                idPublicacion: c.idPublicacion,
                idMascota: c.idMascota,
                texto: c.texto,
                fechaComentario: c.fechaComentario,
                nombreMascota: m?.nombre,
                fotoMascota: m?.fotoPerfil
            )
        }
    }

    func publicarComentario(publicacion: UUID, mascota: UUID, texto: String) async throws {
        let insert = ComentarioInsert(
            idPublicacion: publicacion,
            idMascota: mascota,
            texto: texto.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        try await client
            .from("comentario")
            .insert(insert)
            .execute()
    }

    // MARK: - Amistades entre mascotas
    func amistades(mascota: UUID) async throws -> [AmistadDB] {
        try await client
            .from("amistad_mascota")
            .select()
            .or("id_mascota_1.eq.\(mascota.uuidString),id_mascota_2.eq.\(mascota.uuidString)")
            .execute()
            .value
    }

    func solicitudesPendientes(mascota: UUID) async throws -> [AmistadDB] {
        let todas = try await amistades(mascota: mascota)
        return todas.filter {
            $0.estado.lowercased() == "pendiente" && $0.idMascota2 == mascota
        }
    }

    func amigos(mascota: UUID) async throws -> [AmistadDB] {
        let todas = try await amistades(mascota: mascota)
        return todas.filter { $0.estado.lowercased() == "aceptada" }
    }

    func enviados(mascota: UUID) async throws -> [AmistadDB] {
        let todas = try await amistades(mascota: mascota)
        return todas.filter {
            $0.estado.lowercased() == "pendiente" && $0.idMascota1 == mascota
        }
    }

    func enviarSolicitud(de origen: UUID, a destino: UUID) async throws {
        guard origen != destino else { return }

        // Evitar duplicar
        let yaExiste: [AmistadDB] = try await client
            .from("amistad_mascota")
            .select()
            .or("and(id_mascota_1.eq.\(origen.uuidString),id_mascota_2.eq.\(destino.uuidString)),and(id_mascota_1.eq.\(destino.uuidString),id_mascota_2.eq.\(origen.uuidString))")
            .execute()
            .value

        if !yaExiste.isEmpty {
            throw NSError(domain: "SocialService", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Ya existe una solicitud con esta mascota."])
        }

        let insert = AmistadInsert(
            idMascota1: origen,
            idMascota2: destino,
            estado: "pendiente"
        )
        try await client
            .from("amistad_mascota")
            .insert(insert)
            .execute()
    }

    func responderSolicitud(id: UUID, aceptar: Bool) async throws {
        let update = AmistadEstadoUpdate(
            estado: aceptar ? "aceptada" : "rechazada",
            fechaRespuesta: Date()
        )
        try await client
            .from("amistad_mascota")
            .update(update)
            .eq("id_amistad", value: id)
            .execute()
    }

    // MARK: - Búsqueda por usuario (dueño)
    /// Busca usuarios por nombre, apellidos o correo y devuelve las mascotas de cada uno,
    /// junto con la info del dueño para mostrarla en la UI.
    func buscarPorDueno(query: String, excluyendoMascota: UUID?) async throws -> [MascotaConDueno] {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return [] }

        let patron = "%\(q)%"
        let usuarios: [UsuarioDB] = try await client
            .from("usuario")
            .select()
            .or("nombre.ilike.\(patron),apellidos.ilike.\(patron),correo.ilike.\(patron)")
            .limit(30)
            .execute()
            .value

        guard !usuarios.isEmpty else { return [] }

        let userIds = usuarios.map { $0.id }
        let mascotas: [MascotaDB] = try await client
            .from("mascota")
            .select()
            .in("id_usuario", values: userIds)
            .execute()
            .value

        let usuariosPorId = Dictionary(uniqueKeysWithValues: usuarios.map { ($0.id, $0) })

        return mascotas.compactMap { m in
            guard m.id != excluyendoMascota, let u = usuariosPorId[m.idUsuario] else { return nil }
            return MascotaConDueno(mascota: m, dueno: u)
        }
    }

    /// Trae las mascotas correspondientes a una lista de IDs (para pintar tarjetas de amistad).
    func mascotas(ids: [UUID]) async throws -> [UUID: MascotaDB] {
        guard !ids.isEmpty else { return [:] }
        let mascotas: [MascotaDB] = try await client
            .from("mascota")
            .select()
            .in("id_mascota", values: ids)
            .execute()
            .value
        return Dictionary(uniqueKeysWithValues: mascotas.map { ($0.id, $0) })
    }
}
