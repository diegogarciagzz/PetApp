import Foundation

struct TipoReaccion: Identifiable, Decodable, Equatable {
    let id: UUID
    let icono: String
    let nombre: String
    let activo: Bool

    enum CodingKeys: String, CodingKey {
        case id     = "id_tipo_reaccion"
        case icono
        case nombre
        case activo
    }
}

struct ResumenReaccion: Decodable {
    let idPublicacion: UUID
    let icono: String
    let nombre: String
    let idTipo: UUID
    let total: Int

    enum CodingKeys: String, CodingKey {
        case idPublicacion = "id_publicacion"
        case icono
        case nombre
        case idTipo        = "id_tipo_reaccion"
        case total
    }
}
