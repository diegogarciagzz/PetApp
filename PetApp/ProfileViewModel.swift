//
//  ProfileViewModel.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import SwiftUI
import Combine
import Supabase

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var fotoPerfilURL: String? = nil
    @Published var isUploadingAvatar = false

    func cargarPerfil() async {
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id.uuidString else { return }
        let data: [UsuarioPerfil] = try! await SupabaseManager.shared.client
            .from("usuario")
            .select("foto_perfil")
            .eq("id_usuario", value: userId)
            .limit(1)
            .execute()
            .value
        fotoPerfilURL = data.first?.fotoPerfil
    }

    func actualizarAvatar(image: UIImage) async {
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id.uuidString,
              let data = image.jpegData(compressionQuality: 0.8) else { return }
        isUploadingAvatar = true
        defer { isUploadingAvatar = false }
        do {
            let url = try await StorageManager.shared.subirAvatar(userId: userId, imageData: data)
            try await SupabaseManager.shared.client
                .from("usuario")
                .update(["foto_perfil": url])
                .eq("id_usuario", value: userId)
                .execute()
            fotoPerfilURL = url
        } catch {
            print("Error subiendo avatar: \(error)")
        }
    }
}

struct UsuarioPerfil: Decodable {
    let fotoPerfil: String?
    enum CodingKeys: String, CodingKey {
        case fotoPerfil = "foto_perfil"
    }
}
