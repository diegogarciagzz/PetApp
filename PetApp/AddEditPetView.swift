//
//  AddEditPetView.swift
//  PetApp
//
//  Alta / edición de mascota. Guarda en Supabase y sincroniza
//  `UserSession.shared.myPets`.
//

import SwiftUI
import PhotosUI

struct AddEditPetView: View {
    @Environment(\.dismiss) private var dismiss

    /// Mascota existente (para editar). Si está presente, se ignora `existingPet`.
    let existingMascota: MascotaDB?
    /// Compat con el viejo flujo basado en `Pet`.
    let existingPet: Pet?
    let onSave: (Pet) -> Void

    init(existingPet: Pet? = nil, existingMascota: MascotaDB? = nil, onSave: @escaping (Pet) -> Void) {
        self.existingPet = existingPet
        self.existingMascota = existingMascota
        self.onSave = onSave
    }

    @State private var name: String = ""
    @State private var breed: String = ""
    @State private var ageText: String = ""
    @State private var selectedType: PetType = .dog
    @State private var sexo: String? = nil
    @State private var descripcion: String = ""
    @State private var imagenItem: PhotosPickerItem?
    @State private var imagenPreview: UIImage?
    @State private var fotoExistenteURL: String?

    @State private var guardando = false
    @State private var error: String?

    var isEditing: Bool { existingPet != nil || existingMascota != nil }

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {

                        fotoPicker

                        // Preview emoji animado
                        Text(selectedType.emoji)
                            .font(.system(size: 60))
                            .padding(.top, 4)
                            .animation(.spring(response: 0.3), value: selectedType)

                        inputField(title: "Nombre *", placeholder: "Ej: Luna", text: $name)
                        inputField(title: "Raza", placeholder: "Ej: Labrador", text: $breed)
                        inputField(title: "Edad (años)", placeholder: "Ej: 2", text: $ageText, keyboard: .numberPad)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Tipo de mascota *")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppColors.textPrimary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(PetType.allCases) { type in
                                        Button {
                                            withAnimation(.spring(response: 0.3)) { selectedType = type }
                                        } label: {
                                            HStack(spacing: 6) {
                                                Text(type.emoji).font(.body)
                                                Text(type.rawValue)
                                                    .font(.subheadline.weight(.semibold))
                                                    .foregroundStyle(selectedType == type ? .white : AppColors.textPrimary)
                                            }
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .background(selectedType == type ? AppColors.primary : AppColors.card)
                                            .clipShape(Capsule())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Sexo")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppColors.textPrimary)
                            HStack(spacing: 10) {
                                sexoButton("Macho", value: "M")
                                sexoButton("Hembra", value: "H")
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descripción (opcional)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppColors.textPrimary)
                            TextField("Cuéntanos algo sobre tu mascota...", text: $descripcion, axis: .vertical)
                                .lineLimit(3...5)
                                .padding()
                                .background(AppColors.card)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        if let e = error {
                            Text(e).font(.caption).foregroundStyle(.red)
                        }

                        Button {
                            Task { await guardar() }
                        } label: {
                            HStack {
                                if guardando { ProgressView().tint(.white) }
                                else {
                                    Text(isEditing ? "Guardar cambios" : "Agregar mascota")
                                        .font(.headline)
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isFormValid ? AppColors.primary : Color.gray.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                        .disabled(!isFormValid || guardando)
                    }
                    .padding(AppSpacing.screenPadding)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle(isEditing ? "Editar mascota" : "Nueva mascota")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(AppColors.primary)
                }
            }
            .onAppear { cargarValores() }
            .onChange(of: imagenItem) { _, item in
                Task {
                    if let data = try? await item?.loadTransferable(type: Data.self),
                       let img = UIImage(data: data) {
                        imagenPreview = img
                    }
                }
            }
        }
    }

    // MARK: - Secciones
    private var fotoPicker: some View {
        PhotosPicker(selection: $imagenItem, matching: .images) {
            ZStack {
                Circle()
                    .fill(AppColors.softBeige)
                    .frame(width: 110, height: 110)
                if let img = imagenPreview {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                } else if let url = fotoExistenteURL, !url.isEmpty {
                    RemoteOrDataImage(urlString: url, placeholderSystem: "pawprint.fill", cornerRadius: 55)
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "camera.fill")
                        .font(.title)
                        .foregroundStyle(AppColors.primary)
                }
            }
            .overlay(
                Image(systemName: "pencil.circle.fill")
                    .font(.title3)
                    .foregroundStyle(AppColors.primary)
                    .background(Circle().fill(AppColors.background))
                    .offset(x: 38, y: 38)
            )
        }
        .buttonStyle(.plain)
    }

    private func sexoButton(_ titulo: String, value: String) -> some View {
        Button {
            sexo = (sexo == value) ? nil : value
        } label: {
            Text(titulo)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(sexo == value ? .white : AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(sexo == value ? AppColors.primary : AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private func inputField(title: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .padding()
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Cargar valores iniciales
    private func cargarValores() {
        if let m = existingMascota {
            name = m.nombre
            breed = m.raza ?? ""
            ageText = m.edad.map { "\($0)" } ?? ""
            selectedType = PetType(rawValue: m.tipoAnimal) ?? .other
            sexo = m.sexo
            descripcion = m.descripcion ?? ""
            fotoExistenteURL = m.fotoPerfil
        } else if let p = existingPet {
            name = p.name
            breed = p.breed == "Sin especificar" ? "" : p.breed
            let soloNumeros = p.age.filter { $0.isNumber }
            ageText = soloNumeros.isEmpty ? "" : soloNumeros
            selectedType = p.type
        }
    }

    // MARK: - Guardar
    private func guardar() async {
        guardando = true
        error = nil

        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedBreed = breed.trimmingCharacters(in: .whitespaces)
        let edadInt = Int(ageText.filter { $0.isNumber })

        guard let userId = UserSession.shared.currentUserId else {
            error = "No hay sesión activa."
            guardando = false
            // Fallback local (modo demo sin backend)
            let pet = Pet(
                id: existingPet?.id ?? existingMascota?.id ?? UUID(),
                name: trimmedName,
                breed: trimmedBreed.isEmpty ? "Sin especificar" : trimmedBreed,
                age: edadInt.map { "\($0) años" } ?? "Desconocida",
                type: selectedType,
                emoji: selectedType.emoji
            )
            onSave(pet)
            dismiss()
            return
        }

        do {
            var fotoURL: String? = fotoExistenteURL
            if let img = imagenPreview {
                fotoURL = try await StorageManager.shared.subirImagen(
                    img,
                    bucket: StorageManager.Bucket.mascotas,
                    carpeta: userId.uuidString
                )
            }

            let nuevaMascota: MascotaDB
            if let m = existingMascota {
                nuevaMascota = try await PetService.shared.actualizar(
                    id: m.id,
                    data: MascotaUpdate(
                        nombre: trimmedName,
                        tipoAnimal: selectedType.rawValue,
                        raza: trimmedBreed.isEmpty ? nil : trimmedBreed,
                        edad: edadInt,
                        sexo: sexo,
                        descripcion: descripcion.isEmpty ? nil : descripcion,
                        fotoPerfil: fotoURL
                    )
                )
                if let idx = UserSession.shared.myPets.firstIndex(where: { $0.id == m.id }) {
                    UserSession.shared.myPets[idx] = nuevaMascota
                }
            } else {
                nuevaMascota = try await PetService.shared.crear(
                    MascotaInsert(
                        idUsuario: userId,
                        nombre: trimmedName,
                        tipoAnimal: selectedType.rawValue,
                        raza: trimmedBreed.isEmpty ? nil : trimmedBreed,
                        edad: edadInt,
                        sexo: sexo,
                        descripcion: descripcion.isEmpty ? nil : descripcion,
                        fotoPerfil: fotoURL
                    )
                )
                UserSession.shared.myPets.append(nuevaMascota)
                if UserSession.shared.activePetId == nil {
                    UserSession.shared.activePetId = nuevaMascota.id
                }
            }

            onSave(nuevaMascota.toPet())
            dismiss()
        } catch {
            self.error = "No se pudo guardar: \(error.localizedDescription)"
        }
        guardando = false
    }
}
