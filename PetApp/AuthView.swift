

//
//  AuthView.swift
//  PetApp
//
//
//  AuthView.swift
//  PetApp
//

import SwiftUI

// MARK: - AuthView (raíz de autenticación)
struct AuthView: View {
    @State private var showLogin = true
    @State private var viewModel = AuthViewModel()

    var body: some View {
        if viewModel.isLoggedIn {
            if viewModel.isNewUser {
                FirstPetOnboardingView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            } else {
                MainTabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            }
        } else {
            if showLogin {
                LoginView(viewModel: viewModel, showLogin: $showLogin)
            } else {
                RegisterView(viewModel: viewModel, showLogin: $showLogin)
            }
        }
    }
}

// MARK: - FirstPetOnboardingView
struct FirstPetOnboardingView: View {
    @Bindable var viewModel: AuthViewModel
    @State private var showAddPet = false
    @State private var addedPet: Pet? = nil

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            // Fondo decorativo
            VStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.07))
                    .frame(width: 380, height: 380)
                    .offset(x: 140, y: -130)
                Spacer()
                Circle()
                    .fill(AppColors.softBeige.opacity(0.5))
                    .frame(width: 260, height: 260)
                    .offset(x: -110, y: 90)
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Emoji central
                ZStack {
                    Circle()
                        .fill(AppColors.softBeige)
                        .frame(width: 130, height: 130)

                    Text(addedPet?.emoji ?? "🐾")
                        .font(.system(size: 64))
                        .accessibilityHidden(true)
                }
                .animation(.spring(response: 0.45, dampingFraction: 0.6), value: addedPet?.emoji)
                .padding(.bottom, 36)

                // Texto principal
                Group {
                    if let pet = addedPet {
                        VStack(spacing: 10) {
                            Text("¡\(pet.name) está listo! 🎉")
                                .font(.title2.bold())
                                .foregroundStyle(AppColors.textPrimary)
                                .multilineTextAlignment(.center)

                            Text("Tu primera mascota fue registrada.\nPuedes agregar más desde tu perfil.")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    } else {
                        VStack(spacing: 10) {
                            Text("¡Bienvenido a PetApp!")
                                .font(.title2.bold())
                                .foregroundStyle(AppColors.textPrimary)
                                .multilineTextAlignment(.center)

                            Text("Registra a tu primera mascota para\npersonalizar tu experiencia.")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: addedPet?.name)
                .padding(.horizontal, 32)

                Spacer()

                // Botones
                VStack(spacing: 14) {
                    if addedPet == nil {
                        // Botón principal: agregar mascota
                        Button {
                            showAddPet = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.body)
                                    .accessibilityHidden(true)
                                Text("Agregar mi primera mascota")
                                    .font(.headline)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Agregar primera mascota")

                        // Botón secundario: omitir
                        Button {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                viewModel.isNewUser = false
                            }
                        } label: {
                            Text("Omitir por ahora")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Omitir registro de mascota")

                    } else {
                        // Botón de continuar (tras agregar mascota)
                        Button {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                viewModel.isNewUser = false
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.body)
                                    .accessibilityHidden(true)
                                Text("Entrar a PetApp")
                                    .font(.headline)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Entrar a la aplicación")
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, 50)
            }
        }
        .sheet(isPresented: $showAddPet) {
            AddEditPetView(existingPet: nil) { newPet in
                withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                    addedPet = newPet
                }
            }
            .presentationDetents([.medium, .large])
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

                        if let error = viewModel.errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(.red)
                                    .accessibilityHidden(true)
                                Text(error).font(.caption).foregroundStyle(.red)
                            }
                            .transition(.opacity)
                        }

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

                        Button { } label: {
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
        icon: String, placeholder: String, text: Binding<String>,
        keyboard: UIKeyboardType = .default, isSecure: Bool = false
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

                    VStack(spacing: 14) {
                        registerField(icon: "person",       placeholder: "Nombre",               text: $nombre)
                        registerField(icon: "person",       placeholder: "Apellidos",            text: $apellidos)
                        registerField(icon: "envelope",     placeholder: "Correo electrónico",   text: $email, keyboard: .emailAddress)
                        registerField(icon: "lock",         placeholder: "Contraseña",           text: $password, isSecure: true)
                        registerField(icon: "lock.shield",  placeholder: "Confirmar contraseña", text: $confirmPassword, isSecure: true)

                        if let error = viewModel.errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(.red)
                                    .accessibilityHidden(true)
                                Text(error).font(.caption).foregroundStyle(.red)
                            }
                            .transition(.opacity)
                        }

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
        icon: String, placeholder: String, text: Binding<String>,
        keyboard: UIKeyboardType = .default, isSecure: Bool = false
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
