//
//  DBModels.swift
//  PetApp
//
//  Modelos que mapean 1:1 con las tablas de Supabase.
//

import Foundation

// MARK: - Usuario
struct UsuarioDB: Identifiable, Codable, Hashable {
    var id: UUID
    var nombre: String
    var apellidos: String
    var correo: String
    var fotoPerfil: String?
    var fechaNacimiento: Date?

    enum CodingKeys: String, CodingKey {
        case id               = "id_usuario"
        case nombre
        case apellidos
        case correo
        case fotoPerfil       = "foto_perfil"
        case fechaNacimiento  = "fecha_nacimiento"
    }
}

struct UsuarioUpdate: Encodable {
    let nombre: String
    let apellidos: String
    let fotoPerfil: String?

    enum CodingKeys: String, CodingKey {
        case nombre
        case apellidos
        case fotoPerfil = "foto_perfil"
    }
}

// MARK: - Mascota
struct MascotaDB: Identifiable, Codable, Hashable {
    var id: UUID
    var idUsuario: UUID
    var nombre: String
    var tipoAnimal: String
    var raza: String?
    var edad: Int?
    var sexo: String?
    var descripcion: String?
    var fotoPerfil: String?

    enum CodingKeys: String, CodingKey {
        case id           = "id_mascota"
        case idUsuario    = "id_usuario"
        case nombre
        case tipoAnimal   = "tipo_animal"
        case raza
        case edad
        case sexo
        case descripcion
        case fotoPerfil   = "foto_perfil"
    }

    /// Intenta convertir a un `Pet` para compatibilidad con UI existente.
    func toPet() -> Pet {
        let petType = PetType(rawValue: tipoAnimal) ?? .other
        return Pet(
            id: id,
            name: nombre,
            breed: raza?.isEmpty == false ? raza! : "Sin especificar",
            age: edad.map { "\($0) años" } ?? "Desconocida",
            type: petType,
            emoji: petType.emoji
        )
    }
}

struct MascotaInsert: Encodable {
    let idUsuario: UUID
    let nombre: String
    let tipoAnimal: String
    let raza: String?
    let edad: Int?
    let sexo: String?
    let descripcion: String?
    let fotoPerfil: String?

    enum CodingKeys: String, CodingKey {
        case idUsuario   = "id_usuario"
        case nombre
        case tipoAnimal  = "tipo_animal"
        case raza
        case edad
        case sexo
        case descripcion
        case fotoPerfil  = "foto_perfil"
    }
}

struct MascotaUpdate: Encodable {
    let nombre: String
    let tipoAnimal: String
    let raza: String?
    let edad: Int?
    let sexo: String?
    let descripcion: String?
    let fotoPerfil: String?

    enum CodingKeys: String, CodingKey {
        case nombre
        case tipoAnimal  = "tipo_animal"
        case raza
        case edad
        case sexo
        case descripcion
        case fotoPerfil  = "foto_perfil"
    }
}

// MARK: - Reacción
struct TipoReaccionDB: Identifiable, Decodable, Hashable {
    let id: UUID
    let nombre: String
    let icono: String?
    let activo: Bool

    enum CodingKeys: String, CodingKey {
        case id     = "id_tipo_reaccion"
        case nombre
        case icono
        case activo
    }
}

struct ReaccionDB: Identifiable, Decodable {
    let id: UUID
    let idPublicacion: UUID
    let idMascota: UUID
    let idTipoReaccion: UUID
    let fechaReaccion: Date

    enum CodingKeys: String, CodingKey {
        case id             = "id_reaccion"
        case idPublicacion  = "id_publicacion"
        case idMascota      = "id_mascota"
        case idTipoReaccion = "id_tipo_reaccion"
        case fechaReaccion  = "fecha_reaccion"
    }
}

struct ReaccionInsert: Encodable {
    let idPublicacion: UUID
    let idMascota: UUID
    let idTipoReaccion: UUID

    enum CodingKeys: String, CodingKey {
        case idPublicacion  = "id_publicacion"
        case idMascota      = "id_mascota"
        case idTipoReaccion = "id_tipo_reaccion"
    }
}

// MARK: - Comentario
struct ComentarioDB: Identifiable, Decodable, Hashable {
    let id: UUID
    let idPublicacion: UUID
    let idMascota: UUID
    let texto: String
    let fechaComentario: Date

    enum CodingKeys: String, CodingKey {
        case id              = "id_comentario"
        case idPublicacion   = "id_publicacion"
        case idMascota       = "id_mascota"
        case texto
        case fechaComentario = "fecha_comentario"
    }
}

struct ComentarioInsert: Encodable {
    let idPublicacion: UUID
    let idMascota: UUID
    let texto: String

    enum CodingKeys: String, CodingKey {
        case idPublicacion = "id_publicacion"
        case idMascota     = "id_mascota"
        case texto
    }
}

/// Comentario + datos del autor (de la vista `vista_comentarios_publicacion`).
struct ComentarioConAutor: Identifiable, Decodable, Hashable {
    let id: UUID
    let idPublicacion: UUID
    let idMascota: UUID
    let texto: String
    let fechaComentario: Date
    let nombreMascota: String?
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

// MARK: - Amistad
struct AmistadDB: Identifiable, Decodable, Hashable {
    let id: UUID
    let idMascota1: UUID
    let idMascota2: UUID
    let estado: String
    let fechaSolicitud: Date
    let fechaRespuesta: Date?

    enum CodingKeys: String, CodingKey {
        case id             = "id_amistad"
        case idMascota1     = "id_mascota_1"
        case idMascota2     = "id_mascota_2"
        case estado
        case fechaSolicitud = "fecha_solicitud"
        case fechaRespuesta = "fecha_respuesta"
    }
}

struct AmistadInsert: Encodable {
    let idMascota1: UUID
    let idMascota2: UUID
    let estado: String

    enum CodingKeys: String, CodingKey {
        case idMascota1 = "id_mascota_1"
        case idMascota2 = "id_mascota_2"
        case estado
    }
}

struct AmistadEstadoUpdate: Encodable {
    let estado: String
    let fechaRespuesta: Date

    enum CodingKeys: String, CodingKey {
        case estado
        case fechaRespuesta = "fecha_respuesta"
    }
}

// MARK: - Reporte de pérdida
struct ReporteInsert: Encodable {
    let idMascota: UUID
    let idUsuario: UUID
    let descripcion: String?
    let fotoReferencia: String?
    let ultimaLatConocida: Double?
    let ultimaLonConocida: Double?
    let ultimaUbicacionDesc: String?
    let estado: String

    enum CodingKeys: String, CodingKey {
        case idMascota             = "id_mascota"
        case idUsuario             = "id_usuario"
        case descripcion
        case fotoReferencia        = "foto_referencia"
        case ultimaLatConocida     = "ultima_lat_conocida"
        case ultimaLonConocida     = "ultima_lon_conocida"
        case ultimaUbicacionDesc   = "ultima_ubicacion_desc"
        case estado
    }
}

// MARK: - Avistamiento
struct AvistamientoDB: Identifiable, Decodable, Hashable {
    let id: UUID
    let idReporte: UUID
    let idUsuario: UUID
    let latitud: Double?
    let longitud: Double?
    let descripcionLugar: String?
    let notas: String?
    let fotoAvistamiento: String?
    let fechaAvistamiento: Date

    enum CodingKeys: String, CodingKey {
        case id                = "id_avistamiento"
        case idReporte         = "id_reporte"
        case idUsuario         = "id_usuario"
        case latitud
        case longitud
        case descripcionLugar  = "descripcion_lugar"
        case notas
        case fotoAvistamiento  = "foto_avistamiento"
        case fechaAvistamiento = "fecha_avistamiento"
    }
}

struct AvistamientoInsert: Encodable {
    let idReporte: UUID
    let idUsuario: UUID
    let latitud: Double?
    let longitud: Double?
    let descripcionLugar: String?
    let notas: String?
    let fotoAvistamiento: String?

    enum CodingKeys: String, CodingKey {
        case idReporte         = "id_reporte"
        case idUsuario         = "id_usuario"
        case latitud
        case longitud
        case descripcionLugar  = "descripcion_lugar"
        case notas
        case fotoAvistamiento  = "foto_avistamiento"
    }
}

// MARK: - Publicación (para "Mis publicaciones")
struct PublicacionDB: Identifiable, Decodable, Hashable {
    let id: UUID
    let idMascota: UUID
    let titulo: String?
    let texto: String?
    let imagen: String?
    let estado: String?
    let fechaPublicacion: Date

    enum CodingKeys: String, CodingKey {
        case id               = "id_publicacion"
        case idMascota        = "id_mascota"
        case titulo
        case texto
        case imagen
        case estado
        case fechaPublicacion = "fecha_publicacion"
    }
}

// MARK: - Mensaje / Conversación
struct MensajeDB: Identifiable, Decodable, Hashable {
    let id: UUID
    let idConversacion: UUID
    let idUsuarioEmisor: UUID
    let contenido: String
    let fechaEnvio: Date
    let leido: Bool

    enum CodingKeys: String, CodingKey {
        case id              = "id_mensaje"
        case idConversacion  = "id_conversacion"
        case idUsuarioEmisor = "id_usuario_emisor"
        case contenido
        case fechaEnvio      = "fecha_envio"
        case leido
    }
}
