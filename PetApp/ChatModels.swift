//
//  ChatModels.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import Foundation

struct ConversacionPreview: Identifiable, Decodable {
    let id: UUID
    let idOtroUsuario: UUID
    let nombreOtro: String
    let apellidosOtro: String?
    let fotoOtro: String?
    let ultimoMensaje: String?
    let ultimoMensajeImagen: String?
    let fechaUltimoMensaje: Date?
    let mensajesNoLeidos: Int

    var nombreCompleto: String {
        [nombreOtro, apellidosOtro].compactMap { $0 }.joined(separator: " ")
    }

    enum CodingKeys: String, CodingKey {
        case id                   = "id_conversacion"
        case idOtroUsuario        = "id_otro_usuario"
        case nombreOtro           = "nombre_otro"
        case apellidosOtro        = "apellidos_otro"
        case fotoOtro             = "foto_otro"
        case ultimoMensaje        = "ultimo_mensaje"
        case ultimoMensajeImagen  = "ultimo_mensaje_imagen"
        case fechaUltimoMensaje   = "fecha_ultimo_mensaje"
        case mensajesNoLeidos     = "mensajes_no_leidos"
    }
}

struct Mensaje: Identifiable, Decodable {
    let id: UUID
    let idConversacion: UUID
    let idUsuarioEmisor: UUID
    let contenido: String?
    let imagenUrl: String?
    let fechaEnvio: Date
    var leido: Bool

    enum CodingKeys: String, CodingKey {
        case id               = "id_mensaje"
        case idConversacion   = "id_conversacion"
        case idUsuarioEmisor  = "id_usuario_emisor"
        case contenido
        case imagenUrl        = "imagen_url"
        case fechaEnvio       = "fecha_envio"
        case leido
    }
}
