//
//  StorageManager.swift
//  PetApp
//
//  Manejo de imágenes: intenta subir a Supabase Storage y, si falla
//  (bucket inexistente, permisos, sin internet, etc.), regresa un
//  data URL base64 para que la imagen siga siendo usable en la UI.
//

import Foundation
import SwiftUI
import Supabase
import UIKit

enum StorageError: LocalizedError {
    case conversionFallida
    var errorDescription: String? { "No se pudo convertir la imagen a datos." }
}

final class StorageManager {
    static let shared = StorageManager()
    private let client = SupabaseManager.shared.client

    /// Buckets esperados en Supabase. Si no existen, se usa fallback.
    enum Bucket {
        static let publicaciones = "publicaciones"
        static let mascotas      = "mascotas"
        static let reportes      = "reportes"
        static let avistamientos = "avistamientos"
        static let perfiles      = "perfiles"
    }

    /// Sube una imagen y devuelve la URL pública.
    /// Si la subida falla, genera un data URL base64 como fallback
    /// (útil cuando los buckets de Supabase no están configurados).
    func subirImagen(_ imagen: UIImage, bucket: String, carpeta: String) async throws -> String {
        guard let data = imagen.jpegData(compressionQuality: 0.7) else {
            throw StorageError.conversionFallida
        }

        let nombreArchivo = "\(carpeta)/\(UUID().uuidString).jpg"

        do {
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
        } catch {
            print("⚠️ Storage falló (\(bucket)): \(error.localizedDescription). Usando data URL de respaldo.")
            return dataURL(from: data)
        }
    }

    /// Convierte datos JPEG a un `data:` URL base64, reducido para no saturar la DB.
    private func dataURL(from data: Data) -> String {
        let reducida = reducir(data: data, aAncho: 600) ?? data
        let base64 = reducida.base64EncodedString()
        return "data:image/jpeg;base64,\(base64)"
    }

    private func reducir(data: Data, aAncho maxAncho: CGFloat) -> Data? {
        guard let img = UIImage(data: data) else { return nil }
        let escala = min(1.0, maxAncho / max(img.size.width, 1))
        if escala >= 1.0 { return data }
        let nuevoTamano = CGSize(width: img.size.width * escala, height: img.size.height * escala)
        let renderer = UIGraphicsImageRenderer(size: nuevoTamano)
        let nueva = renderer.image { _ in
            img.draw(in: CGRect(origin: .zero, size: nuevoTamano))
        }
        return nueva.jpegData(compressionQuality: 0.6)
    }
}

// MARK: - Helper para cargar imágenes desde URL o data URL.
struct RemoteOrDataImage: View {
    let urlString: String?
    let placeholderSystem: String
    var cornerRadius: CGFloat = 0
    var height: CGFloat? = nil

    var body: some View {
        Group {
            if let s = urlString, !s.isEmpty {
                if s.hasPrefix("data:"), let uiImg = decodeDataURL(s) {
                    Image(uiImage: uiImg)
                        .resizable()
                        .scaledToFill()
                } else if let url = URL(string: s) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        case .failure:
                            fallback
                        default:
                            ProgressView()
                        }
                    }
                } else {
                    fallback
                }
            } else {
                fallback
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var fallback: some View {
        ZStack {
            Color(.secondarySystemBackground)
            Image(systemName: placeholderSystem)
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
        }
    }

    private func decodeDataURL(_ s: String) -> UIImage? {
        guard let comaIdx = s.firstIndex(of: ",") else { return nil }
        let base64 = String(s[s.index(after: comaIdx)...])
        guard let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }
}
