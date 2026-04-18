import SwiftUI
import Combine
import Supabase

@MainActor
class ReactionViewModel: ObservableObject {
    @Published var tipos: [TipoReaccion] = []
    @Published var resumen: [ResumenReaccion] = []
    @Published var miReaccion: UUID? = nil
    @Published var showPicker = false

    let idPublicacion: UUID
    private let idUsuario: UUID

    var totalReacciones: Int { resumen.reduce(0) { $0 + $1.total } }

    var top3: [ResumenReaccion] {
        Array(resumen.sorted { $0.total > $1.total }.prefix(3))
    }

    init(idPublicacion: UUID) {
        self.idPublicacion = idPublicacion
        self.idUsuario = SupabaseManager.shared.client.auth.currentUser?.id ?? UUID()
    }

    func cargar() async {
        async let fetchTipos: [TipoReaccion] = SupabaseManager.shared.client
            .from("tipo_reaccion")
            .select()
            .eq("activo", value: true)
            .execute()
            .value

        async let fetchResumen: [ResumenReaccion] = SupabaseManager.shared.client
            .from("vista_reacciones")
            .select()
            .eq("id_publicacion", value: idPublicacion.uuidString)
            .execute()
            .value

        do {
            let (t, r) = try await (fetchTipos, fetchResumen)
            tipos   = t
            resumen = r
        } catch {
            print("❌ Error cargando reacciones: \(error)")
        }

        // Mi reacción actual
        struct MiReaccionRow: Decodable {
            let idTipo: UUID
            enum CodingKeys: String, CodingKey {
                case idTipo = "id_tipo_reaccion"   // ← corregido
            }
        }
        do {
            let rows: [MiReaccionRow] = try await SupabaseManager.shared.client
                .from("reaccion")
                .select("id_tipo_reaccion")         // ← corregido
                .eq("id_publicacion", value: idPublicacion.uuidString)
                .eq("id_usuario", value: idUsuario.uuidString)
                .execute()
                .value
            miReaccion = rows.first?.idTipo
        } catch {
            print("❌ Error leyendo mi reacción: \(error)")
        }
    }

    func reaccionar(tipo: TipoReaccion) async {
        showPicker = false
        if miReaccion == tipo.id {
            await quitarReaccion()
        } else {
            await upsertReaccion(tipo: tipo)
        }
        await cargar()
    }

    private func upsertReaccion(tipo: TipoReaccion) async {
        struct Row: Encodable {
            let id_publicacion: String
            let id_usuario: String
            let id_tipo_reaccion: String             // ← corregido
        }
        do {
            try await SupabaseManager.shared.client
                .from("reaccion")
                .upsert(Row(
                    id_publicacion:   idPublicacion.uuidString,
                    id_usuario:       idUsuario.uuidString,
                    id_tipo_reaccion: tipo.id.uuidString   // ← corregido
                ), onConflict: "id_publicacion,id_usuario")
                .execute()
            miReaccion = tipo.id
        } catch {
            print("❌ Error upsert reacción: \(error)")
        }
    }

    private func quitarReaccion() async {
        do {
            try await SupabaseManager.shared.client
                .from("reaccion")
                .delete()
                .eq("id_publicacion", value: idPublicacion.uuidString)
                .eq("id_usuario", value: idUsuario.uuidString)
                .execute()
            miReaccion = nil
        } catch {
            print("❌ Error quitando reacción: \(error)")
        }
    }
}
