//
//  StorageManager.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import Foundation
import Supabase
import UIKit

class StorageManager {
    static let shared = StorageManager()
    private let client = SupabaseManager.shared.client

    /// Sube una imagen y regresa la URL pública
    func subirImagen(_ imagen: UIImage, bucket: String, carpeta: String) async throws -> String {
        guard let data = imagen.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "StorageManager", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "No se pudo convertir la imagen"])
        }

        let nombreArchivo = "\(carpeta)/\(UUID().uuidString).jpg"

        try await client.storage
            .from(bucket)
            .upload(
                path: nombreArchivo,
                file: data,
                options: FileOptions(contentType: "image/jpeg")
            )

        let urlPublica = try client.storage
            .from(bucket)
            .getPublicURL(path: nombreArchivo)

        return urlPublica.absoluteString
    }
    func subirAvatar(userId: String, imageData: Data) async throws -> String {
        let path = "avatares/\(userId)/avatar.jpg"
        try await SupabaseManager.shared.client.storage
            .from("avatares")
            .upload(path, data: imageData, options: .init(
                cacheControl: "3600",
                contentType: "image/jpeg",
                upsert: true   // sobreescribe si ya existe
            ))
        let url = try SupabaseManager.shared.client.storage
            .from("avatares")
            .getPublicURL(path: path)
        return url.absoluteString
    }
}
