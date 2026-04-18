//
//  ProfileView.swift
//  PetApp
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var authVM
    @State private var session = UserSession.shared

    @State private var showEditProfile = false
    @State private var showShareAlert = false
    @State private var selectedBadge: String?

    @State private var showAddPet = false
    @State private var mascotaToEdit: MascotaDB?
    @State private var mascotaToDelete: MascotaDB?
    @State private var showDeleteAlert = false

    @State private var showMyPosts = false
    @State private var showMyReports = false
    @State private var showSettings = false

    @State private var cargando = false
    @State private var error: String?

    // Fallbacks cuando aún no hay sesión cargada.
    private let fallbackUser = MockData.user

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        profileHeader
                        statsSection
                        quickActions
                        badgesSection
                        petsSection
                        profileMenuSection

                        if let error = error {
                            Text(error).font(.caption).foregroundStyle(.red)
                        }
                    }
                    .padding(AppSpacing.screenPadding)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if !session.isLoaded { await session.refresh() }
            }
            .refreshable { await session.refresh() }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(user: session.currentUser) { updated in
                    session.currentUser = updated
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showAddPet) {
                AddEditPetView(existingPet: nil, existingMascota: nil) { _ in }
                    .presentationDetents([.large])
            }
            .sheet(item: $mascotaToEdit) { pet in
                AddEditPetView(existingPet: nil, existingMascota: pet) { _ in }
                    .presentationDetents([.large])
            }
            .sheet(isPresented: $showMyPosts) {
                MisPublicacionesView()
                    .presentationDetents([.large])
            }
            .sheet(isPresented: $showMyReports) {
                MisReportesView()
                    .presentationDetents([.large])
            }
            .sheet(isPresented: $showSettings) {
                AjustesView()
                    .environment(authVM)
                    .presentationDetents([.medium, .large])
            }
            .sheet(item: $selectedBadge) { badge in
                BadgeDetailSheet(badgeTitle: badge)
                    .presentationDetents([.medium])
            }
            .alert("Eliminar mascota", isPresented: $showDeleteAlert, presenting: mascotaToDelete) { pet in
                Button("Eliminar", role: .destructive) {
                    Task { await eliminar(pet) }
                }
                Button("Cancelar", role: .cancel) {}
            } message: { pet in
                Text("¿Estás seguro de que quieres eliminar a \(pet.nombre)?")
            }
            .alert("Perfil compartido", isPresented: $showShareAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Tu perfil se compartió correctamente.")
            }
        }
    }

    // MARK: - Header
    private var profileHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppColors.softBeige)
                    .frame(width: 96, height: 96)
                if let foto = session.currentUser?.fotoPerfil, !foto.isEmpty {
                    RemoteOrDataImage(urlString: foto, placeholderSystem: "person.fill", cornerRadius: 48)
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(AppColors.primary)
                }
            }

            Text(displayName)
                .font(.title3.bold())
                .foregroundStyle(AppColors.textPrimary)

            if let correo = session.currentUser?.correo {
                Text(correo)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Text(fallbackUser.city)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)

            if let activa = session.activePet {
                Text("Mascota activa: \(activa.nombre) \(PetType(rawValue: activa.tipoAnimal)?.emoji ?? "🐾")")
                    .font(.caption)
                    .foregroundStyle(AppColors.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppColors.primary.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var displayName: String {
        if let u = session.currentUser {
            return "\(u.nombre) \(u.apellidos)".trimmingCharacters(in: .whitespaces)
        }
        return fallbackUser.name
    }

    // MARK: - Stats
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(title: "Mascotas", value: "\(session.myPets.count)")
            StatCard(title: "Posts", value: "\(fallbackUser.postsCount)")
            StatCard(title: "Reportes", value: "\(fallbackUser.reportsCount)")
        }
    }

    // MARK: - Quick Actions
    private var quickActions: some View {
        HStack(spacing: 12) {
            Button { showEditProfile = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.pencil")
                    Text("Editar perfil").font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(.plain)

            Button { showShareAlert = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Compartir").font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Badges
    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Logros")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    badgeCard(title: "Rescatista", subtitle: "3 reportes creados", icon: "heart.fill")
                    badgeCard(title: "Explorer", subtitle: "5 lugares guardados", icon: "map.fill")
                    badgeCard(title: "Comunidad", subtitle: "12 posts compartidos", icon: "person.3.fill")
                }
            }
        }
    }

    private func badgeCard(title: String, subtitle: String, icon: String) -> some View {
        Button { selectedBadge = title } label: {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    Circle().fill(AppColors.softBeige).frame(width: 42, height: 42)
                    Image(systemName: icon).foregroundStyle(AppColors.primary)
                }
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(AppColors.textPrimary)
                Text(subtitle).font(.caption).foregroundStyle(AppColors.textSecondary)
            }
            .frame(width: 150, alignment: .leading)
            .padding()
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Pets
    private var petsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionTitle("Mis mascotas")
                Spacer()
                Button { showAddPet = true } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Agregar").font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(AppColors.primary)
                }
            }

            if session.myPets.isEmpty {
                VStack(spacing: 12) {
                    Text("🐾").font(.system(size: 40))
                    Text("Aún no tienes mascotas registradas")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                    Button { showAddPet = true } label: {
                        Text("+ Agregar primera mascota")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(AppColors.primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(session.myPets) { pet in
                        petCard(pet: pet)
                    }
                }
            }
        }
    }

    private func petCard(pet: MascotaDB) -> some View {
        let petType = PetType(rawValue: pet.tipoAnimal) ?? .other
        let esActiva = session.activePetId == pet.id
        return VStack(spacing: 8) {
            if let foto = pet.fotoPerfil, !foto.isEmpty {
                RemoteOrDataImage(urlString: foto, placeholderSystem: "pawprint.fill", cornerRadius: 30)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } else {
                Text(petType.emoji).font(.system(size: 40))
            }

            Text(pet.nombre)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)

            Text(pet.raza ?? "Sin raza")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            Text(pet.tipoAnimal)
                .font(.caption2)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(colorForPetType(petType))
                .clipShape(Capsule())

            if let edad = pet.edad {
                Text("\(edad) años")
                    .font(.caption2)
                    .foregroundStyle(AppColors.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.softBeige.opacity(0.7))
                    .clipShape(Capsule())
            }

            Button {
                session.setActivePet(pet.id)
            } label: {
                Text(esActiva ? "Activa" : "Usar como activa")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(esActiva ? .white : AppColors.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(esActiva ? AppColors.primary : AppColors.primary.opacity(0.15))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            HStack(spacing: 10) {
                Button { mascotaToEdit = pet } label: {
                    Image(systemName: "pencil")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.primary)
                        .padding(8)
                        .background(AppColors.softBeige)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Button {
                    mascotaToDelete = pet
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func colorForPetType(_ type: PetType) -> Color {
        switch type {
        case .dog: return AppColors.primary
        case .cat: return .orange
        case .turtle: return .green
        case .rabbit: return .pink
        case .hamster: return .yellow
        case .bird: return .blue
        case .other: return AppColors.primary
        }
    }

    // MARK: - Menu
    private var profileMenuSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Opciones")
            profileOption(title: "Mis publicaciones", icon: "photo.on.rectangle") { showMyPosts = true }
            profileOption(title: "Mis reportes", icon: "exclamationmark.bubble.fill") { showMyReports = true }
            profileOption(title: "Configuración", icon: "gearshape.fill") { showSettings = true }
        }
    }

    private func profileOption(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon).foregroundStyle(AppColors.primary)
                Text(title).foregroundStyle(AppColors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(AppColors.textSecondary)
            }
            .padding()
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(AppColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func eliminar(_ pet: MascotaDB) async {
        do {
            try await PetService.shared.eliminar(id: pet.id)
            session.myPets.removeAll { $0.id == pet.id }
            if session.activePetId == pet.id {
                session.activePetId = session.myPets.first?.id
            }
        } catch {
            self.error = "No se pudo eliminar: \(error.localizedDescription)"
        }
    }
}

// MARK: - StatCard
struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value).font(.title3.bold()).foregroundStyle(AppColors.textPrimary)
            Text(title).font(.caption).foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - Edit Profile
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    let user: UsuarioDB?
    var onSaved: (UsuarioDB) -> Void

    @State private var nombre: String = ""
    @State private var apellidos: String = ""
    @State private var imagenItem: PhotosPickerItem?
    @State private var imagenPreview: UIImage?

    @State private var guardando = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        fotoPicker
                        inputField(title: "Nombre", text: $nombre)
                        inputField(title: "Apellidos", text: $apellidos)

                        if let e = error {
                            Text(e).font(.caption).foregroundStyle(.red)
                        }

                        Button {
                            Task { await guardar() }
                        } label: {
                            HStack {
                                if guardando { ProgressView().tint(.white) }
                                else { Text("Guardar cambios").font(.headline) }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                        .disabled(guardando)
                    }
                    .padding(AppSpacing.screenPadding)
                }
            }
            .navigationTitle("Editar perfil")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                nombre = user?.nombre ?? ""
                apellidos = user?.apellidos ?? ""
            }
            .onChange(of: imagenItem) { _, item in
                Task {
                    if let data = try? await item?.loadTransferable(type: Data.self),
                       let img = UIImage(data: data) {
                        imagenPreview = img
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(AppColors.primary)
                }
            }
        }
    }

    private var fotoPicker: some View {
        PhotosPicker(selection: $imagenItem, matching: .images) {
            ZStack {
                Circle().fill(AppColors.softBeige).frame(width: 110, height: 110)
                if let img = imagenPreview {
                    Image(uiImage: img).resizable().scaledToFill()
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                } else if let url = user?.fotoPerfil, !url.isEmpty {
                    RemoteOrDataImage(urlString: url, placeholderSystem: "person.fill", cornerRadius: 55)
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill").font(.title).foregroundStyle(AppColors.primary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func inputField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(AppColors.textPrimary)
            TextField(title, text: text)
                .padding()
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func guardar() async {
        guard let u = user else {
            error = "Perfil no disponible."
            return
        }
        guardando = true
        error = nil
        do {
            var fotoURL = u.fotoPerfil
            if let img = imagenPreview {
                fotoURL = try await StorageManager.shared.subirImagen(
                    img,
                    bucket: StorageManager.Bucket.perfiles,
                    carpeta: u.id.uuidString
                )
            }
            let actualizado = try await ProfileService.shared.actualizar(
                id: u.id,
                nombre: nombre,
                apellidos: apellidos,
                fotoPerfil: fotoURL
            )
            UserSession.shared.currentUser = actualizado
            onSaved(actualizado)
            dismiss()
        } catch {
            self.error = "No se pudo guardar: \(error.localizedDescription)"
        }
        guardando = false
    }
}

// MARK: - Mis publicaciones
struct MisPublicacionesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var publicaciones: [PublicacionDB] = []
    @State private var cargando = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                Group {
                    if cargando {
                        ProgressView()
                    } else if publicaciones.isEmpty {
                        ContentUnavailableView(
                            "Sin publicaciones",
                            systemImage: "photo.on.rectangle",
                            description: Text("Aún no has publicado nada.")
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(publicaciones) { p in
                                    publicacionCard(p)
                                }
                            }
                            .padding(AppSpacing.screenPadding)
                        }
                    }
                }
            }
            .navigationTitle("Mis publicaciones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }.foregroundStyle(AppColors.primary)
                }
            }
            .task { await cargar() }
        }
    }

    private func publicacionCard(_ p: PublicacionDB) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let img = p.imagen, !img.isEmpty {
                RemoteOrDataImage(urlString: img, placeholderSystem: "photo", cornerRadius: 14, height: 180)
            }
            if let t = p.titulo, !t.isEmpty {
                Text(t).font(.subheadline.weight(.semibold))
            }
            if let tx = p.texto {
                Text(tx).font(.subheadline).foregroundStyle(AppColors.textPrimary)
            }
            Text(p.fechaPublicacion.formatted(.relative(presentation: .named)))
                .font(.caption2).foregroundStyle(AppColors.textSecondary)
        }
        .padding(12)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func cargar() async {
        cargando = true
        defer { cargando = false }
        guard let mascota = UserSession.shared.activePetId else { return }
        publicaciones = (try? await PetService.shared.publicacionesDe(mascota: mascota)) ?? []
    }
}

// MARK: - Mis reportes
struct MisReportesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var reportes: [MascotaPerdida] = []
    @State private var cargando = false
    @State private var seleccion: MascotaPerdida?

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                Group {
                    if cargando {
                        ProgressView()
                    } else if reportes.isEmpty {
                        ContentUnavailableView(
                            "Sin reportes",
                            systemImage: "exclamationmark.bubble",
                            description: Text("Aún no has creado reportes de mascotas.")
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(reportes) { r in
                                    Button { seleccion = r } label: {
                                        ReporteCardView(reporte: r)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(AppSpacing.screenPadding)
                        }
                    }
                }
            }
            .navigationTitle("Mis reportes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }.foregroundStyle(AppColors.primary)
                }
            }
            .task { await cargar() }
            .sheet(item: $seleccion) { r in
                ReporteDetailView(reporte: r) {
                    Task { await cargar() }
                }
                .presentationDetents([.large])
            }
        }
    }

    private func cargar() async {
        cargando = true
        defer { cargando = false }
        guard let uid = UserSession.shared.currentUserId else { return }
        reportes = (try? await ReportService.shared.reportesDe(usuario: uid)) ?? []
    }
}

// MARK: - Ajustes
struct AjustesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var authVM

    @State private var notifPush = true
    @State private var notifMail = false
    @State private var modoOscuro = false
    @State private var confirmarLogout = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                Form {
                    Section("Notificaciones") {
                        Toggle("Notificaciones push", isOn: $notifPush)
                        Toggle("Notificaciones por correo", isOn: $notifMail)
                    }
                    Section("Preferencias") {
                        Toggle("Modo oscuro (próximamente)", isOn: $modoOscuro)
                            .disabled(true)
                    }
                    Section("Cuenta") {
                        if let u = UserSession.shared.currentUser {
                            LabeledContent("Correo", value: u.correo)
                        }
                        Button(role: .destructive) {
                            confirmarLogout = true
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Cerrar sesión")
                            }
                        }
                    }
                    Section {
                        LabeledContent("Versión", value: "1.0.0")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }.foregroundStyle(AppColors.primary)
                }
            }
            .alert("¿Cerrar sesión?", isPresented: $confirmarLogout) {
                Button("Cerrar sesión", role: .destructive) {
                    Task {
                        await authVM.logout()
                        dismiss()
                    }
                }
                Button("Cancelar", role: .cancel) {}
            }
        }
    }
}

// MARK: - Badge Detail (sin cambios)
struct BadgeDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let badgeTitle: String

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "rosette")
                        .font(.system(size: 42))
                        .foregroundStyle(AppColors.primary)
                    Text(badgeTitle)
                        .font(.title3.bold())
                        .foregroundStyle(AppColors.textPrimary)
                    Text(messageForBadge(badgeTitle))
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button { dismiss() } label: {
                        Text("Cerrar")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                }
                .padding(AppSpacing.screenPadding)
            }
            .navigationTitle("Logro")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func messageForBadge(_ title: String) -> String {
        switch title {
        case "Rescatista": return "Has participado activamente creando reportes y apoyando a la comunidad."
        case "Explorer": return "Exploraste y guardaste lugares pet friendly para tus salidas."
        case "Comunidad": return "Compartiste publicaciones e interactuaste con otros dueños de mascotas."
        default: return "Logro desbloqueado dentro de la comunidad."
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}
