//
//  AuthView.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import SwiftUI

struct AuthView: View {
    @State private var showLogin = true
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            MainTabView()
        } else {
            if showLogin {
                LoginView(isLoggedIn: $isLoggedIn, showLogin: $showLogin)
            } else {
                RegisterView(isLoggedIn: $isLoggedIn, showLogin: $showLogin)
            }
        }
    }
}

// MARK: - LoginView
struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var showLogin: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            // Fondo decorativo
            VStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.08))
                    .frame(width: 350, height: 350)
                    .offset(x: 120, y: -100)

                Spacer()

                Circle()
                    .fill(AppColors.softBeige.opacity(0.6))
                    .frame(width: 250, height: 250)
                    .offset(x: -100, y: 80)
            }
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {

                    // MARK: - Hero
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppColors.softBeige)
                                .frame(width: 100, height: 100)

                            Text("🐾")
                                .font(.system(size: 50))
                                .accessibilityHidden(true)
                        }
                        .padding(.top, 60)

                        Text("PetApp")
                            .font(.largeTitle.bold())
                            .foregroundStyle(AppColors.textPrimary)

                        Text("La comunidad de mascotas de México")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 48)

                    // MARK: - Formulario
                    VStack(spacing: 16) {
                        authField(
                            icon: "envelope",
                            placeholder: "Correo electrónico",
                            text: $email,
                            keyboard: .emailAddress
                        )

                        authField(
                            icon: "lock",
                            placeholder: "Contraseña",
                            text: $password,
                            isSecure: true
                        )

                        if showError {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(.red)
                                    .accessibilityHidden(true)
                                Text("Correo o contraseña incorrectos")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                            .transition(.opacity)
                        }

                        // Botón login
                        Button {
                            handleLogin()
                        } label: {
                            HStack(spacing: 10) {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(0.9)
                                } else {
                                    Text("Iniciar sesión")
                                        .font(.headline)
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                        .disabled(isLoading)
                        .accessibilityLabel("Iniciar sesión")
                        .padding(.top, 8)

                        // Olvidé contraseña
                        Button {
                            // TODO: recuperar contraseña
                        } label: {
                            Text("¿Olvidaste tu contraseña?")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.primary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)

                    // MARK: - Divider
                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(AppColors.textSecondary.opacity(0.3))
                            .frame(height: 1)

                        Text("o")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)

                        Rectangle()
                            .fill(AppColors.textSecondary.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.vertical, 24)

                    // MARK: - Demo rápido
                    Button {
                        withAnimation {
                            isLoggedIn = true
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "play.circle.fill")
                                .accessibilityHidden(true)
                            Text("Entrar sin cuenta (Demo)")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.primary.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .accessibilityLabel("Entrar en modo demo sin crear cuenta")

                    // MARK: - Registro
                    HStack(spacing: 4) {
                        Text("¿No tienes cuenta?")
                            .foregroundStyle(AppColors.textSecondary)

                        Button {
                            withAnimation(.easeInOut) {
                                showLogin = false
                            }
                        } label: {
                            Text("Regístrate")
                                .fontWeight(.semibold)
                                .foregroundStyle(AppColors.primary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Ir a crear una cuenta nueva")
                    }
                    .font(.subheadline)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showError)
    }

    // MARK: - Lógica login
    private func handleLogin() {
        guard !email.isEmpty && !password.isEmpty else {
            showError = true
            return
        }
        isLoading = true
        showError = false

        // Simula autenticación
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            // Demo: cualquier credencial funciona
            if email.contains("@") && password.count >= 4 {
                withAnimation {
                    isLoggedIn = true
                }
            } else {
                showError = true
            }
        }
    }

    // MARK: - Campo de texto
    private func authField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        isSecure: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.primary)
                .frame(width: 20)
                .accessibilityHidden(true)

            if isSecure {
                SecureField(placeholder, text: text)
                    .accessibilityLabel(placeholder)
            } else {
                TextField(placeholder, text: text)
                    .keyboardType(keyboard)
                    .autocapitalization(.none)
                    .accessibilityLabel(placeholder)
            }
        }
        .padding()
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.primary.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - RegisterView
struct RegisterView: View {
    @Binding var isLoggedIn: Bool
    @Binding var showLogin: Bool

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var passwordMismatch = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            // Fondo decorativo
            VStack {
                Circle()
                    .fill(AppColors.softBeige.opacity(0.6))
                    .frame(width: 300, height: 300)
                    .offset(x: -120, y: -80)
                Spacer()
                Circle()
                    .fill(AppColors.primary.opacity(0.06))
                    .frame(width: 280, height: 280)
                    .offset(x: 120, y: 60)
            }
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {

                    // MARK: - Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppColors.softBeige)
                                .frame(width: 90, height: 90)
                            Text("🐶")
                                .font(.system(size: 44))
                                .accessibilityHidden(true)
                        }
                        .padding(.top, 50)

                        Text("Crear cuenta")
                            .font(.title.bold())
                            .foregroundStyle(AppColors.textPrimary)

                        Text("Únete a la comunidad pet lover")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.bottom, 36)

                    // MARK: - Formulario
                    VStack(spacing: 14) 