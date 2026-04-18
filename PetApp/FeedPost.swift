import Foundation

struct FeedPost: Identifiable, Decodable {
    let id: UUID
    let titulo: String?
    let texto: String?
    let imagen: String?
    let fechaPublicacion: Date
    let idMascota: UUID
    let nombreMascota: String
    let fotoMascota: String?
    let raza: String?
    let totalReacciones: Int
    let totalComentarios: Int
    let popularidad: Int

    enum CodingKeys: String, CodingKey {
        case id               = "id_publicacion"
        case titulo
        case texto
        case imagen
        case fechaPublicacion = "fecha_publicacion"
        case idMascota        = "id_mascota"
        case nombreMascota    = "nombre_mascota"
        case fotoMascota      = "foto_mascota"
        case raza
        case totalReacciones  = "total_reacciones"
        case totalComentarios = "total_comentarios"
        case popularidad
    }
}

struct FeedPostAmigos: Decodable {
    let id: UUID
    let titulo: String?
    let texto: String?
    let imagen: String?
    let fechaPublicacion: Date
    let idMascota: UUID
    let nombreMascota: String
    let fotoMascota: String?
    let raza: String?
    let totalReacciones: Int
    let totalComentarios: Int
    let popularidad: Int
    let espectador1: UUID
    let espectador2: UUID

    enum CodingKeys: String, CodingKey {
        case id               = "id_publicacion"
        case titulo
        case texto
        case imagen
        case fechaPublicacion = "fecha_publicacion"
        case idMascota        = "id_mascota"
        case nombreMascota    = "nombre_mascota"
        case fotoMascota      = "foto_mascota"
        case raza
        case totalReacciones  = "total_reacciones"
        case totalComentarios = "total_comentarios"
        case popularidad
        case espectador1      = "espectador_1"
        case espectador2      = "espectador_2"
    }

    func toFeedPost() -> FeedPost {
        FeedPost(
            id: id,
            titulo: titulo,
            texto: texto,
            imagen: imagen,
            fechaPublicacion: fechaPublicacion,
            idMascota: idMascota,
            nombreMascota: nombreMascota,
            fotoMascota: fotoMascota,
            raza: raza,
            totalReacciones: totalReacciones,
            totalComentarios: totalComentarios,
            popularidad: popularidad
        )
    }
}
