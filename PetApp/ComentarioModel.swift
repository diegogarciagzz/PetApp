//
//  ComentarioModel.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import Foundation

struct Comentario: Identifiable, Decodable {
    let id: UUID
    let idPublicacion: UUID
    let idMascota: UUID
    let texto: String
    let fechaComentario: Date
    let nombreMascota: String
    let fotoMascota: String?

    enum CodingKeys: String, CodingKey {
        case id              = "id_comentario"
        case idPublicacion   = "id_publicacion"
        case idMascota       = "id_mascota"
        case texto
        case fechaComentario = "fecha_comentario"
        case nombreMascota   = "nombre_mascota"
        case fotoMascota     = "foto_mascota"
    }
}
