//
//  AuthViewModel.swift
//  PetApp
//
//  @Observable conecta AuthService con LoginView y RegisterView.
//  Reemplaza la lógica de simulación con llamadas reales a Supabase.
//

import Foundation
import SwiftUI
import Supabase

@MainActor
@Observable
class AuthViewModel {
    var isLoggedIn: Bool = false
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private let client = SupabaseManager.shared.client

    init() {
        // Revisar si ya hay sesión activa al arrancar la app
        Task { await checkSession() }
    }

    // MARK: - Verificar sesión existente
    func checkSession() async {
        do {
            let session = try await client.auth.session
            isLoggedIn = session.user.id != UUID(uuidString: "00000000-0000-0000-0000-000000000000")
        } catch {
            isLoggedIn = false
        }
    }

    // MARK: - Login
    func login(email: String, password: String) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Completa todos los campos."
            return
        }
        isLoading = true
        errorMessage = nil

        do {
            try await AuthService.shared.signIn(email: email, password: password)
            isLoggedIn = true
        } catch {
            errorMessage = mensajeAmigable(error)
        }
        isLoading = false
    }

    // MARK: - Registro
    func register(
        nombre: String,
        apellidos: String,
        email: String,
        password: String,
        confirmPassword: String
    ) async {
        guard password == confirmPassword else {
            errorMessage = "Las contraseñas no coinciden."
            return
        }
        guard password.count >= 6 else {
            errorMessage = "La contraseña debe tener al menos 6 caracteres."
            return
        }
        isLoading = true
        errorMessage = nil

        do {
            try await AuthService.shared.signUp(
                nombre: nombre,
                apellidos: apellidos,
                email: email,
                password: password
            )
            isLoggedIn = true
        } catch {
            errorMessage = mensajeAmigable(error)
        }
        isLoading = false
    }

    // MARK: - Logout
    func logout() async {
        do {
            try await AuthService.shared.signOut()
            isLoggedIn = false
        } catch {
            errorMessage = mensajeAmigable(error)
        }
    }

    // MARK: - Mensajes de error legibles
    private func mensajeAmigable(_ error: Error) -> String {
        let msg = error.localizedDescription.lowercased()
        if msg.contains("invalid login") || msg.contains("invalid credentials") {
            return "Correo o contraseña incorrectos."
        } else if msg.contains("already registered") || msg.contains("already exists") {
            return "Este correo ya tiene una cuenta registrada."
        } else if msg.contains("network") || msg.contains("internet") {
            return "Sin conexión. Revisa tu internet."
        } else {
            return error.localizedDescription
        }
    }
}
