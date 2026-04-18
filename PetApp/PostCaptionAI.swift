//
//  PostCaptionAI.swift
//  PetApp
//
//  Genera sugerencias de título y descripción para publicaciones sociales
//  usando plantillas lingüísticas on-device (sin APIs externas).
//

import Foundation

enum PostCaptionAI {

    // MARK: - Sugerencias de título

    static func titleSuggestions(petName: String, petType: String) -> [String] {
        let name = petName.isEmpty ? "Mi mascota" : petName
        let emoji = emojiFor(petType)

        let all: [String] = [
            "¡\(name) en modo aventura! \(emoji)🐾",
            "\(name) conquistando el día \(emoji)✨",
            "El mundo según \(name) \(emoji)",
            "Momento \(name) del día ☀️",
            "\(name) siendo el más adorable 💕",
            "Las travesuras de \(name) \(emoji)😄",
            "¡Imposible resistirse a \(name)! \(emoji)",
            "\(name) y sus mejores poses 📸",
            "Un día perfecto con \(name) \(emoji)🌿",
            "\(name) es puro amor ❤️",
        ]
        return Array(all.shuffled().prefix(4))
    }

    // MARK: - Sugerencias de descripción

    static func descriptionSuggestions(petName: String, petType: String) -> [String] {
        let name = petName.isEmpty ? "Mi mascota" : petName
        let emoji = emojiFor(petType)

        let all: [String] = [
            "\(name) tuvo un día increíble y no podíamos no compartirlo \(emoji)",
            "Capturando los mejores momentos de \(name). ¿Alguien más tiene un compañero tan especial? 🐾",
            "La vida es definitivamente mejor con \(name) a nuestro lado. 💕",
            "Este es \(name), el rey/reina indiscutible de nuestra casa \(emoji)👑",
            "¿Qué haríamos sin \(name)? Cada día es una aventura nueva. ✨",
            "\(name) nos recuerda cada día por qué las mascotas son lo mejor del mundo \(emoji)",
            "Hoy \(name) fue especialmente adorable. Guardando este recuerdo para siempre 📸",
        ]
        return Array(all.shuffled().prefix(3))
    }

    // MARK: - Helper

    private static func emojiFor(_ type: String) -> String {
        switch type.lowercased() {
        case "perro":                       return "🐶"
        case "gato":                        return "🐱"
        case "pájaro", "pajaro":            return "🐦"
        case "conejo":                      return "🐰"
        case "hámster", "hamster":          return "🐹"
        case "tortuga":                     return "🐢"
        default:                            return "🐾"
        }
    }
}
