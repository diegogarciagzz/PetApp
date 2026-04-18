//
//  AddEditPetView.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//


//
//  AddEditPetView.swift
//  PetApp
//

import SwiftUI

struct AddEditPetView: View {
    @Environment(\.dismiss) private var dismiss

    let existingPet: Pet?
    let onSave: (Pet) -> Void

    @State private var name: String = ""
    @State private var breed: String = ""
    @State private var age: String = ""
    @State private var selectedType: PetType = .dog

    var isEditing: Bool { existingPet != nil }

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // Preview emoji animado
                        Text(selectedType.emoji)
                            .font(.system(size: 80))
                            .padding(.top, 8)
                            .animation(.spring(response: 0.3), value: selectedType)

                        // Nombre
                        inputField(title: "Nombre *", placeholder: "Ej: Luna", text: $name)

                        // Raza
                        inputField(title: "Raza", placeholder: "Ej: Labrador Retriever", text: $breed)

                        // Edad
                        inputField(title: "Edad", placeholder: "Ej: 2 años", text: $age)

                        // Selector de tipo
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Tipo de mascota *")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppColors.textPrimary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(PetType.allCases) { type in
                                        Button {
                                            withAnimation(.spring(response: 0.3)) {
                                                selectedType = type
                                            }
                                        } label: {
                                            HStack(spacing: 6) {
                                                Text(type.emoji)
                                                    .font(.body)
                                                Text(type.rawValue)
                                                    .font(.subheadline.weight(.semibold))
                                                    .foregroundStyle(
                                                        selectedType == type ? .white : AppColors.textPrimary
                                                    )
                                            }
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .background(
                                                selectedType == type
                                                    ? AppColors.primary
                                                    : AppColors.card
                                            )
                                            .clipShape(Capsule())
                                        }
                                        .buttonStyle(.plain)
                                        .accessibilityLabel(type.rawValue)
                                    }
                                }
                            }
                        }

                        // Botón guardar
                        Button {
                            let trimmedName = name.trimmingCharacters(in: .whitespaces)
                            let trimmedBreed = breed.trimmingCharacters(in: .whitespaces)
                            let trimmedAge = age.trimmingCharacters(in: .whitespaces)

                            let pet = Pet(
                                id: existingPet?.id ?? UUID(),
                                name: trimmedName,
                                breed: trimmedBreed.isEmpty ? "Sin especificar" : trimmedBreed,
                                age: trimmedAge.isEmpty ? "Desconocida" : trimmedAge,
                                type: selectedType,
                                emoji: selectedType.emoji
                            )
                            onSave(pet)
                            dismiss()
                        } label: {
                            Text(isEditing ? "Guardar cambios" : "Agregar mascota")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(isFormValid ? AppColors.primary : Color.gray.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                        .disabled(!isFormValid)
                        .accessibilityLabel(isEditing ? "Guardar cambios" : "Agregar mascota")
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
            .onAppear {
                if let pet = existingPet {
                    name = pet.name
                    breed = pet.breed == "Sin especificar" ? "" : pet.breed
                    age = pet.age == "Desconocida" ? "" : pet.age
                    selectedType = pet.type
                }
            }
        }
    }

    private func inputField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
            TextField(placeholder, text: text)
                .padding()
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}