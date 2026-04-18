//
//  AmistadModels.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import Foundation

enum EstadoAmistad: String, Decodable {
    case pendiente = "pendiente"
    case aceptado  = "aceptado"
    case rechazado = "rechazado"
}

struct Amistad: Identifiable, Decodable {
    let id: UUID
    let estado: EstadoAmistad
    let fechaSolicitud: Date
    let idSolicitante: UUID
    let nombreSolicitante: String
    let fotoSolicitante: String?
    let tipoSolicitante: String?
    let idReceptor: UUID
    let nombreReceptor: String
    let fotoReceptor: String?
    let tipoReceptor: String?

    enum CodingKeys: String, CodingKey {
        case id               = "id_amistad"
        case estado
        case fechaSolicitud   = "fecha_solicitud"
        case idSolicitante    = "id_solicitante"
        case nombreSolicitante = "nombre_solicitante"
        case fotoSolicitante  = "foto_solicitante"
        case tipoSolicitante  = "tipo_solicitante"
        case idReceptor       = "id_receptor"
        case nombreReceptor   = "nombre_receptor"
        case fotoReceptor     = "foto_receptor"
        case tipoReceptor     = "tipo_receptor"
    }

    func nombreAmigo(miId: UUID) -> String {
        miId == idSolicitante ? nombreReceptor : nombreSolicitante
    }
    func fotoAmigo(miId: UUID) -> String? {
        miId == idSolicitante ? fotoReceptor : fotoSolicitante
    }
    func tipoAmigo(miId: UUID) -> String? {
        miId == idSolicitante ? tipoReceptor : tipoSolicitante
    }
    func idAmigo(miId: UUID) -> UUID {
        miId == idSolicitante ? idReceptor : idSolicitante
    }
}
