//
//  AuthView.swift
//  PetApp
//
//  REEMPLAZA el AuthView.swift original.
//  Cambios vs original:
//    - Usa @State var viewModel = AuthViewModel() en lugar de @State isLoggedIn
//    - handleLogin() y handleRegister() llaman a AuthViewModel (Supabase real)
//    - El botón Demo sigue funcionando igual
//    - Todos los @Binding isLoggedIn → reemplazados por el ViewModel
//

import SwiftUI

struct AuthView: View {
    @State private var showLogin = true
    @State private var viewModel = AuthViewModel()

    var body: some View {
        if viewModel.isLoggedIn {
            MainTabView()
        } else {
            if showLogin {
                LoginView(viewModel: viewModel, showLogin: $showLogin)
            } else {
                RegisterView(viewModel: viewModel, showLogin: $showLogin)
            }
        }
    }
}

// MARK: - LoginView
struct LoginView: View {
    @Bindable var viewModel: AuthViewModel
    @Binding var showLogin: Bool

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

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

                    // Hero
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

                    // Formulario
                    VStack(spacing: 16) {
                        authField(icon: "envelope", placeholder: "Correo electrónico",
                                  text: $email, keyboard: .emailAddress)
                        authField(icon: "lock", placeholder: "Contraseña",
                                  text: $password, isSecure: true)

                        // Error
                        if let error = viewModel.errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(.red)
                                    .accessibilityHidden(true)
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                            .transition(.opacity)
                        }

                        // Botón login
                        Button {
                            Task { await viewModel.login(email: email, password: password) }
                        } label: {
                            HStack(spacing: 10) {
                                if viewModel.isLoading {
                                    ProgressView().tint(.white).scaleEffect(0.9)
                                } else {
                                    Text("Iniciar sesión").font(.headline)
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.isLoading)
                        .padding(.top, 8)

                        Button { /* TODO: recuperar contraseña */ } label: {
                            Text("¿Olvidaste tu contraseña?")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.primary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)

                    // Divider
                    HStack(spacing: 12) {
                        Rectangle().fill(AppColors.textSecondary.opacity(0.3)).frame(height: 1)
                        Text("o").font(.caption).foregroundStyle(AppColors.textSecondary)
                        Rectangle().fill(AppColors.textSecondary.opacity(0.3)).frame(height: 1)
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.vertical, 24)

                    // Demo
                    Button {
                        withAnimation { viewModel.isLoggedIn = true }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "play.circle.fill").accessibilityHidden(true)
                            Text("Entrar sin cuenta (Demo)").font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.primary.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, AppSpacing.screenPadding)

                    // Ir a registro
                    HStack(spacing: 4) {
                        Text("¿No tienes cuenta?").foregroundStyle(AppColors.textSecondary)
                        Button {
                            withAnimation(.easeInOut) { showLogin = false }
                        } label: {
                            Text("Regístrate").fontWeight(.semibold).foregroundStyle(AppColors.primary)
                        }
                        .buttonStyle(.plain)
                    }
                    .font(.subheadline)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.errorMessage)
    }

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
                SecureField(placeholder, text: text).accessibilityLabel(placeholder)
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
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.primary.opacity(0.15), lineWidth: 1))
    }
}

// MARK: - RegisterView
struct RegisterView: View {
    @Bindable var viewModel: AuthViewModel
    @Binding var showLogin: Bool

    @State private var nombre = ""
    @State private var apellidos = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {

                    // Header
                    HStack {
                        Button {
                            withAnimation(.easeInOut) { showLogin = true }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(AppColors.primary)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.top, 60)

                    VStack(spacing: 8) {
                        Text("Crear cuenta")
                            .font(.title.bold())
                            .foregroundStyle(AppColors.textPrimary)
                        Text("Únete a la comunidad de mascotas")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.vertical, 32)

                    // Formulario
                    VStack(spacing: 14) {
                        registerField(icon: "person",       placeholder: "Nombre",              text: $nombre)
                        registerField(icon: "person",       placeholder: "Apellidos",           text: $apellidos)
                        registerField(icon: "envelope",     placeholder: "Correo electrónico",  text: $email, keyboard: .emailAddress)
                        registerField(icon: "lock",         placeholder: "Contraseña",          text: $password, isSecure: true)
                        registerField(icon: "lock.shield",  placeholder: "Confirmar contraseña",text: $confirmPassword, isSecure: true)

                        // Error
                        if let error = viewModel.errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(.red)
                                    .accessibilityHidden(true)
                                Text(error).font(.caption).foregroundStyle(.red)
                            }
                            .transition(.opacity)
                        }

                        // Botón registrar
                        Button {
                            Task {
                                await viewModel.register(
                                    nombre: nombre,
                                    apellidos: apellidos,
                                    email: email,
                                    password: password,
                                    confirmPassword: confirmPassword
                                )
                            }
                        } label: {
                            HStack(spacing: 10) {
                                if viewModel.isLoading {
                                    ProgressView().tint(.white).scaleEffect(0.9)
                                } else {
                                    Text("Crear cuenta").font(.headline)
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.isLoading)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)

                    // Ir a login
                    HStack(spacing: 4) {
                        Text("¿Ya tienes cuenta?").foregroundStyle(AppColors.textSecondary)
                        Button {
                            withAnimation(.easeInOut) { showLogin = true }
                        } label: {
                            Text("Inicia sesión").fontWeight(.semibold).foregroundStyle(AppColors.primary)
                        }
                        .buttonStyle(.plain)
                    }
                    .font(.subheadline)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.errorMessage)
    }

    private func registerField(
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
                SecureField(placeholder, text: text).accessibilityLabel(placeholder)
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
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.primary.opacity(0.15), lineWidth: 1))
    }
}
