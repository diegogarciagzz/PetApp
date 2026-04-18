//
//  ProfileView.swift
//  PetApp
//

import SwiftUI

struct ProfileView: View {
    let user = MockData.user

    @State private var pets: [Pet] = MockData.pets
    @State private var showEditProfile = false
    @State private var showShareAlert = false
    @State private var selectedMenuTitle: String?
    @State private var selectedBadge: String?
    @State private var showAddPet = false
    @State private var petToEdit: Pet? = nil
    @State private var petToDelete: Pet? = nil
    @State private var showDeleteAlert = false
    @StateObject private var vm = ProfileViewModel()
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? = nil

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
                        recentActivitySection
                        profileMenuSection
                    }
                    .padding(AppSpacing.screenPadding)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(user: user)
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showAddPet) {
                AddEditPetView(existingPet: nil) { newPet in
                    pets.append(newPet)
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(item: $petToEdit) { pet in
                AddEditPetView(existingPet: pet) { updatedPet in
                    if let index = pets.firstIndex(where: { $0.id == updatedPet.id }) {
                        pets[index] = updatedPet
                    }
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(item: $selectedMenuTitle) { title in
                MenuDetailSheet(title: title)
                    .presentationDetents([.medium])
            }
            .sheet(item: $selectedBadge) { badge in
                BadgeDetailSheet(badgeTitle: badge)
                    .presentationDetents([.medium])
            }
            .alert("Eliminar mascota", isPresented: $showDeleteAlert, presenting: petToDelete) { pet in
                Button("Eliminar", role: .destructive) {
                    pets.removeAll { $0.id == pet.id }
                }
                Button("Cancelar", role: .cancel) {}
            } message: { pet in
                Text("¿Estás seguro de que quieres eliminar a \(pet.name)?")
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
            ZStack(alignment: .bottomTrailing) {
                // Foto de perfil
                Group {
                    if let urlStr = vm.fotoPerfilURL, let url = URL(string: urlStr) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable().scaledToFill()
                            default:
                                Image(systemName: "person.fill")
                                    .font(.system(size: 38))
                                    .foregroundStyle(AppColors.primary)
                            }
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 38))
                            .foregroundStyle(AppColors.primary)
                    }
                }
                .frame(width: 96, height: 96)
                .background(AppColors.softBeige)
                .clipShape(Circle())

                // Botón cámara
                Button {
                    showImagePicker = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 28, height: 28)
                        if vm.isUploadingAvatar {
                            ProgressView().tint(.white).scaleEffect(0.7)
                        } else {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .disabled(vm.isUploadingAvatar)
                .offset(x: 4, y: 4)
            }
            .accessibilityLabel("Foto de perfil de \(user.name). Toca para cambiar.")

            Text(user.name)
                .font(.title3.bold())
                .foregroundStyle(AppColors.textPrimary)
            // ... resto igual
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .onChange(of: selectedImage) { _, newImage in
            guard let img = newImage else { return }
            Task { await vm.actualizarAvatar(image: img) }
        }
        .onAppear {
            Task { await vm.cargarPerfil() }
        }
    }

    // MARK: - Stats
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(title: "Mascotas", value: "\(pets.count)")
            StatCard(title: "Posts", value: "\(user.postsCount)")
            StatCard(title: "Reportes", value: "\(user.reportsCount)")
        }
    }

    // MARK: - Quick Actions
    private var quickActions: some View {
        HStack(spacing: 12) {
            Button {
                showEditProfile = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.pencil").accessibilityHidden(true)
                    Text("Editar perfil").font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Editar perfil")

            Button {
                showShareAlert = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up").accessibilityHidden(true)
                    Text("Compartir").font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Compartir perfil")
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
        Button {
            selectedBadge = title
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    Circle()
                        .fill(AppColors.softBeige)
                        .frame(width: 42, height: 42)
                    Image(systemName: icon)
                        .foregroundStyle(AppColors.primary)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(width: 150, alignment: .leading)
            .padding()
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(subtitle)")
    }

    // MARK: - Pets
    private var petsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionTitle("Mis mascotas")
                Spacer()
                Button {
                    showAddPet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Agregar")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(AppColors.primary)
                }
                .accessibilityLabel("Agregar mascota")
            }

            if pets.isEmpty {
                VStack(spacing: 12) {
                    Text("🐾")
                        .font(.system(size: 40))
                    Text("Aún no tienes mascotas registradas")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                    Button {
                        showAddPet = true
                    } label: {
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
                    ForEach(pets) { pet in
                        petCard(pet: pet)
                    }
                }
            }
        }
    }

    private func petCard(pet: Pet) -> some View {
        VStack(spacing: 8) {
            Text(pet.emoji)
                .font(.system(size: 40))
                .accessibilityHidden(true)

            Text(pet.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)

            Text(pet.breed)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            Text(pet.type.rawValue)
                .font(.caption2)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(colorForPetType(pet.type))
                .clipShape(Capsule())

            Text(pet.age)
                .font(.caption2)
                .foregroundStyle(AppColors.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppColors.softBeige.opacity(0.7))
                .clipShape(Capsule())

            // Botones editar / eliminar
            HStack(spacing: 10) {
                Button {
                    petToEdit = pet
                } label: {
                    Image(systemName: "pencil")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.primary)
                        .padding(8)
                        .background(AppColors.softBeige)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Editar \(pet.name)")

                Button {
                    petToDelete = pet
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
                .accessibilityLabel("Eliminar \(pet.name)")
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

    // MARK: - Recent Activity
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Actividad reciente")
            activityCard(title: "Reporte creado", subtitle: "Publicaste un reporte para Luna en Cumbres.", icon: "exclamationmark.bubble.fill")
            activityCard(title: "Lugar guardado", subtitle: "Agregaste Parque Rufino Tamayo a tus favoritos.", icon: "bookmark.fill")
            activityCard(title: "Coincidencia IA", subtitle: "La IA detectó una posible coincidencia cercana a tu zona.", icon: "sparkles")
        }
    }

    private func activityCard(title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppColors.softBeige)
                    .frame(width: 46, height: 46)
                Image(systemName: icon)
                    .foregroundStyle(AppColors.primary)
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
        }
        .padding()
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(subtitle)")
    }

    // MARK: - Menu
    private var profileMenuSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Opciones")
            profileOption(title: "Mis publicaciones", icon: "photo.on.rectangle")
            profileOption(title: "Mis reportes", icon: "exclamationmark.bubble.fill")
            profileOption(title: "Configuración", icon: "gearshape.fill")
        }
    }

    private func profileOption(title: String, icon: String) -> some View {
        Button {
            selectedMenuTitle = title
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(AppColors.primary)
                    .accessibilityHidden(true)
                Text(title).foregroundStyle(AppColors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppColors.textSecondary)
                    .accessibilityHidden(true)
            }
            .padding()
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(AppColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - StatCard
struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(AppColors.textPrimary)
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

// MARK: - Edit Profile
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    let user: UserProfile

    @State private var name: String = ""
    @State private var username: String = ""
    @State private var city: String = ""
    @State private var bio: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        inputField(title: "Nombre", text: $name)
                        inputField(title: "Usuario", text: $username)
                        inputField(title: "Ciudad", text: $city)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bio")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppColors.textPrimary)
                            TextEditor(text: $bio)
                                .frame(height: 120)
                                .padding(10)
                                .background(AppColors.card)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        Button {
                            dismiss()
                        } label: {
                            Text("Guardar cambios")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppColors.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(AppSpacing.screenPadding)
                }
            }
            .navigationTitle("Editar perfil")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                name = user.name
                username = user.username
                city = user.city
                bio = user.bio
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(AppColors.primary)
                }
            }
        }
    }

    private func inputField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
            TextField(title, text: text)
                .padding()
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Menu Detail
struct MenuDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: iconForTitle(title))
                        .font(.system(size: 42))
                        .foregroundStyle(AppColors.primary)
                        .accessibilityHidden(true)
                    Text(title)
                        .font(.title3.bold())
                        .foregroundStyle(AppColors.textPrimary)
                    Text(descriptionForTitle(title))
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button {
                        dismiss()
                    } label: {
                        Text("Entendido")
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
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func iconForTitle(_ title: String) -> String {
        switch title {
        case "Mis publicaciones": return "photo.on.rectangle"
        case "Mis reportes": return "exclamationmark.bubble.fill"
        case "Configuración": return "gearshape.fill"
        default: return "person.circle.fill"
        }
    }

    private func descriptionForTitle(_ title: String) -> String {
        switch title {
        case "Mis publicaciones": return "Aquí aparecerán todas las publicaciones sociales que hayas compartido."
        case "Mis reportes": return "Aquí consultarás tus reportes de mascotas perdidas o encontradas."
        case "Configuración": return "Aquí podrás personalizar notificaciones, privacidad y accesibilidad."
        default: return "Sección del perfil."
        }
    }
}

// MARK: - Badge Detail
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
                        .accessibilityHidden(true)
                    Text(badgeTitle)
                        .font(.title3.bold())
                        .foregroundStyle(AppColors.textPrimary)
                    Text(messageForBadge(badgeTitle))
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button {
                        dismiss()
                    } label: {
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

#Preview {
    ProfileView()
}
