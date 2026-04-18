//
//  PetService.swift
//  PetApp
//
//  CRUD de mascotas en Supabase.
//

import Foundation
import Supabase

final class PetService {
    static let shared = PetService()
    private let client = SupabaseManager.shared.client
    private init() {}

    func crear(_ data: MascotaInsert) async throws -> MascotaDB {
        let nueva: MascotaDB = try await client
            .from("mascota")
            .insert(data)
            .select()
            .single()
            .execute()
            .value
        return nueva
    }

    func actualizar(id: UUID, data: MascotaUpdate) async throws -> MascotaDB {
        let actualizada: MascotaDB = try await client
            .from("mascota")
            .update(data)
            .eq("id_mascota", value: id)
            .select()
            .single()
            .execute()
            .value
        return actualizada
    }

    func eliminar(id: UUID) async throws {
        try await client
            .from("mascota")
            .delete()
            .eq("id_mascota", value: id)
            .execute()
    }

    func misMascotas(idUsuario: UUID) async throws -> [MascotaDB] {
        try await client
            .from("mascota")
            .select()
            .eq("id_usuario", value: idUsuario)
            .order("fecha_registro", ascending: true)
            .execute()
            .value
    }

    func publicacionesDe(mascota: UUID) async throws -> [PublicacionDB] {
        try await client
            .from("publicacion")
            .select()
            .eq("id_mascota", value: mascota)
            .order("fecha_publicacion", ascending: false)
            .execute()
            .value
    }
}

final class ProfileService {
    static let shared = ProfileService()
    private let client = SupabaseManager.shared.client
    private init() {}

    func actualizar(id: UUID, nombre: String, apellidos: String, fotoPerfil: String?) async throws -> UsuarioDB {
        let update = UsuarioUpdate(nombre: nombre, apellidos: apellidos, fotoPerfil: fotoPerfil)
        let u: UsuarioDB = try await client
            .from("usuario")
            .update(update)
            .eq("id_usuario", value: id)
            .select()
            .single()
            .execute()
            .value
        return u
    }
}
