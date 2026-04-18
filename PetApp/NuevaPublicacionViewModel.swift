//
//  NuevaPublicacionViewModel.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
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

    // TODO: reemplaza por el id_mascota del usuario logueado
    let idMascotaActual: UUID = UUID(uuidString: "b1000000-0000-0000-0000-000000000001")!

    private let client = SupabaseManager.shared.client

    var puedePublicar: Bool {
        !texto.trimmingCharacters(in: .whitespaces).isEmpty || imagenPreview != nil
    }

    func cargarImagen(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            imagenPreview = uiImage
        }
    }

    func publicar() async {
        isLoading = true
        errorMessage = nil

        do {
            var urlImagen: String? = nil

            // 1. Subir foto si hay una seleccionada
            if let imagen = imagenPreview {
                urlImagen = try await StorageManager.shared.subirImagen(
                    imagen,
                    bucket: "publicaciones",
                    carpeta: idMascotaActual.uuidString
                )
            }

            // 2. Insertar publicación en la DB
            let nuevaPublicacion = NuevaPublicacionPayload(
                idMascota: idMascotaActual,
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

// Payload para el INSERT
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
