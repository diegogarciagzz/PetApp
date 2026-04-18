//
//  NuevaPublicacionViewModel.swift
//  PetApp
//

import Foundation
import PhotosUI
import SwiftUI
import Combine
import Supabase

@MainActor
class NuevaPublicacionViewModel: ObservableObject {
    @Published var titulo = ""
    @Published var texto = ""
    @Published var imagenSeleccionada: PhotosPickerItem?
    @Published var imagenPreview: UIImage?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var publicacionExitosa = false

    // AI: validación de imagen
    @Published var isValidatingImage = false
    @Published var imageValidated = false   // true cuando pasó la validación

    // AI: sugerencias de caption / descripción
    @Published var titleSuggestions: [String] = []
    @Published var descriptionSuggestions: [String] = []

    var idMascotaActual: UUID? { UserSession.shared.activePetId }

    private let client = SupabaseManager.shared.client

    var puedePublicar: Bool {
        guard !isValidatingImage else { return false }
        // Si hay imagen, debe haber pasado la validación
        if imagenPreview != nil && !imageValidated { return false }
        return (!texto.trimmingCharacters(in: .whitespaces).isEmpty || imagenPreview != nil)
            && idMascotaActual != nil
    }

    // MARK: - Carga y validación de imagen

    func cargarImagen(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else { return }

        imagenPreview = uiImage
        imageValidated = false
        isValidatingImage = true
        errorMessage = nil

        let esMascota = await PetImageValidator.containsPet(uiImage)
        isValidatingImage = false

        if esMascota {
            imageValidated = true
            errorMessage = nil
            refreshSuggestions()
        } else {
            imagenPreview = nil
            imagenSeleccionada = nil
            imageValidated = false
            errorMessage = "Solo se permiten fotos de mascotas 🐾 Asegúrate de que la imagen muestre a tu mascota claramente."
        }
    }

    // MARK: - Sugerencias AI

    func refreshSuggestions() {
        let mascota = UserSession.shared.myPets.first(where: { $0.id == idMascotaActual })
        let nombre = mascota?.nombre ?? ""
        let tipo = mascota?.tipoAnimal ?? ""
        titleSuggestions = PostCaptionAI.titleSuggestions(petName: nombre, petType: tipo)
        descriptionSuggestions = PostCaptionAI.descriptionSuggestions(petName: nombre, petType: tipo)
    }

    // MARK: - Publicar

    func publicar() async {
        guard let mascota = idMascotaActual else {
            errorMessage = "Necesitas registrar una mascota antes de publicar."
            return
        }
        isLoading = true
        errorMessage = nil

        do {
            var urlImagen: String? = nil

            if let imagen = imagenPreview {
                urlImagen = try await StorageManager.shared.subirImagen(
                    imagen,
                    bucket: StorageManager.Bucket.publicaciones,
                    carpeta: mascota.uuidString
                )
            }

            let nuevaPublicacion = NuevaPublicacionPayload(
                idMascota: mascota,
                titulo: titulo.isEmpty ? nil : titulo,
                texto: texto.isEmpty ? nil : texto,
                imagen: urlImagen
            )

            try await client
                .from("publicacion")
                .insert(nuevaPublicacion)
                .execute()

            publicacionExitosa = true

        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error al publicar: \(error)")
        }

        isLoading = false
    }
}

// MARK: - Payload para el INSERT
struct NuevaPublicacionPayload: Encodable {
    let idMascota: UUID
    let titulo: String?
    let texto: String?
    let imagen: String?

    enum CodingKeys: String, CodingKey {
        case idMascota = "id_mascota"
        case titulo
        case texto
        case imagen
    }
}
