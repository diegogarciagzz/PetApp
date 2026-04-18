//
//  ProfileViewModel.swift
//  PetApp
//

import SwiftUI
import Combine
import Supabase

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var fotoPerfilURL: String? = nil
    @Published var isUploadingAvatar      = false
    @Published var idMascotaActiva: UUID? = nil
    @Published var nombre: String         = ""

    func cargarPerfil() async {
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id.uuidString else { return }

        struct PerfilRow: Decodable {
            let fotoPerfil: String?
            let nombre: String?
            let apellidos: String?
            enum CodingKeys: String, CodingKey {
                case fotoPerfil = "foto_perfil"
                case nombre     = "nombre"
                case apellidos  = "apellidos"
            }
        }

        do {
            let rows: [PerfilRow] = try await SupabaseManager.shared.client
                .from("usuario")
                .select("foto_perfil, nombre, apellidos")
                .eq("id_usuario", value: userId)
                .limit(1)
                .execute()
                .value

            if let row = rows.first {
                fotoPerfilURL = row.fotoPerfil
                nombre = "\(row.nombre ?? "") \(row.apellidos ?? "")".trimmingCharacters(in: .whitespaces)
            }
        } catch {
            print("❌ Error cargando perfil: \(error)")
        }

        await cargarMascotaActiva()
    }

    private func cargarMascotaActiva() async {
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id else { return }
        struct Row: Decodable {
            let id: UUID
            enum CodingKeys: String, CodingKey { case id = "id_mascota" }
        }
        do {
            let rows: [Row] = try await SupabaseManager.shared.client
                .from("mascota")
                .select("id_mascota")
                .eq("id_usuario", value: userId.uuidString)
                .limit(1)
                .execute()
                .value
            idMascotaActiva = rows.first?.id
        } catch {
            print("❌ Error cargando mascota activa: \(error)")
        }
    }

    func actualizarAvatar(image: UIImage) async {
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id else { return }
        isUploadingAvatar = true
        defer { isUploadingAvatar = false }
        do {
            let url = try await StorageManager.shared.subirImagen(
                image,
                bucket: StorageManager.Bucket.perfiles,
                carpeta: userId.uuidString
            )
            struct AvatarUpdate: Encodable {
                let foto_perfil: String
            }
            try await SupabaseManager.shared.client
                .from("usuario")
                .update(AvatarUpdate(foto_perfil: url))
                .eq("id_usuario", value: userId.uuidString)
                .execute()
            fotoPerfilURL = url
        } catch {
            print("❌ Error subiendo avatar: \(error)")
        }
    }
}

struct UsuarioPerfil: Decodable {
    let fotoPerfil: String?
    enum CodingKeys: String, CodingKey {
        case fotoPerfil = "foto_perfil"
    }
}
