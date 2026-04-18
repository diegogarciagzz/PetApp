//
//  AuthService.swift
//  PetApp
//
//  Maneja login, registro y cierre de sesión con Supabase Auth.
//  Después del registro crea el row en public.usuario.
//

import Foundation
import Supabase
import UIKit

class AuthService {
    static let shared = AuthService()
    private let client = SupabaseManager.shared.client
    private init() {}

    // MARK: - Registro
    /// Crea cuenta en Supabase Auth y luego inserta en public.usuario.
    /// Si se pasa una imagen, la sube a storage (o usa data URL fallback) y la guarda
    /// como `foto_perfil`.
    func signUp(
        nombre: String,
        apellidos: String,
        email: String,
        password: String,
        fotoPerfil: UIImage? = nil
    ) async throws {
        // 1. Crear cuenta en Auth
        let response = try await client.auth.signUp(
            email: email,
            password: password
        )

        let userId = response.user.id

        // 2. Subir foto (si se proveyó)
        var fotoURL: String? = nil
        if let img = fotoPerfil {
            fotoURL = try await StorageManager.shared.subirImagen(
                img,
                bucket: StorageManager.Bucket.perfiles,
                carpeta: userId.uuidString
            )
        }

        // 3. Insertar perfil en public.usuario
        let perfil = UsuarioInsert(
            id_usuario: userId,
            nombre: nombre,
            apellidos: apellidos,
            correo: email,
            foto_perfil: fotoURL
        )

        try await client
            .from("usuario")
            .insert(perfil)
            .execute()
    }

    // MARK: - Login
    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(
            email: email,
            password: password
        )
    }

    // MARK: - Logout
    func signOut() async throws {
        try await client.auth.signOut()
    }

    // MARK: - Sesión activa
    var currentUserId: UUID? {
        client.auth.currentUser?.id
    }
}

// MARK: - Struct para insertar en public.usuario
struct UsuarioInsert: Encodable {
    let id_usuario: UUID
    let nombre: String
    let apellidos: String
    let correo: String
    let foto_perfil: String?
}

// MARK: - Errores custom
enum AuthError: LocalizedError {
    case noUserId
    case passwordMismatch

    var errorDescription: String? {
        switch self {
        case .noUserId:        return "No se pudo obtener el ID de usuario."
        case .passwordMismatch: return "Las contraseñas no coinciden."
        }
    }
}
