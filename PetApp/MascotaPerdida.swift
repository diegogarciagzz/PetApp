//
//  MascotaPerdida.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import Foundation

struct MascotaPerdida: Identifiable, Decodable {
    let id: UUID
    let fechaReporte: Date
    let descripcion: String?
    let fotoReferencia: String?
    let ultimaLat: Double?
    let ultimaLon: Double?
    let ultimaUbicacionDesc: String?
    let idMascota: UUID
    let nombreMascota: String
    let tipoAnimal: String
    let raza: String?
    let fotoMascota: String?
    let edad: Int?
    let sexo: String?
    let idDueno: UUID
    let nombreDueno: String
    let totalAvistamientos: Int

    enum CodingKeys: String, CodingKey {
        case id                   = "id_reporte"
        case fechaReporte         = "fecha_reporte"
        case descripcion
        case fotoReferencia       = "foto_referencia"
        case ultimaLat            = "ultima_lat_conocida"
        case ultimaLon            = "ultima_lon_conocida"
        case ultimaUbicacionDesc  = "ultima_ubicacion_desc"
        case idMascota            = "id_mascota"
        case nombreMascota        = "nombre_mascota"
        case tipoAnimal           = "tipo_animal"
        case raza
        case fotoMascota          = "foto_mascota"
        case edad
        case sexo
        case idDueno              = "id_dueno"
        case nombreDueno          = "nombre_dueno"
        case totalAvistamientos   = "total_avistamientos"
    }
}
