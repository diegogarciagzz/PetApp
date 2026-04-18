//
//  PetDescriptionAI.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import Foundation

/// Motor de IA on-device para generar descripciones estructuradas de mascotas.
/// Usa reglas lingüísticas y contexto para producir texto natural sin APIs externas.
struct PetDescriptionAI {

    // MARK: - Función principal
    static func generateDescription(
        name: String,
        type: String,
        color: String,
        location: String,
        details: String,
        status: String
    ) -> String {

        guard !name.isEmpty || !color.isEmpty || !location.isEmpty else {
            return ""
        }

        var parts: [String] = []

        // 1. Apertura según estado
        let opening = buildOpening(name: name, type: type, status: status)
        parts.append(opening)

        // 2. Descripción física
        if !color.isEmpty {
            let physical = buildPhysical(type: type, color: color)
            parts.append(physical)
        }

        // 3. Ubicación
        if !location.isEmpty {
            let loc = buildLocation(location: location, status: status)
            parts.append(loc)
        }

        // 4. Detalles adicionales
        if !details.isEmpty {
            parts.append("Información adicional: \(details.trimmingCharacters(in: .whitespacesAndNewlines)).")
        }

        // 5. Llamada a la acción
        let cta = buildCTA(status: status)
        parts.append(cta)

        return parts.joined(separator: " ")
    }

    // MARK: - Helpers privados

    private static func buildOpening(name: String, type: String, status: String) -> String {
        let animal = type.lowercased()
        let petName = name.isEmpty ? "Una mascota" : (status == "Perdido" ? "\(name)" : "Se encontró a \(name)")

        if status == "Perdido" {
            if name.isEmpty {
                return "Se perdió un \(animal)."
            } else {
                return "Se perdió \(petName), un \(animal)."
            }
        } else {
            if name.isEmpty {
                return "Se encontró un \(animal)."
            } else {
                return "\(petName), un \(animal)."
            }
        }
    }

    private static func buildPhysical(type: String, color: String) -> String {
        let color = color.lowercased().trimmingCharacters(in: .whitespaces)
        return "Es de color \(color)."
    }

    private static func buildLocation(location: String, status: String) -> String {
        let loc = location.trimmingCharacters(in: .whitespacesAndNewlines)
        if status == "Perdido" {
            return "Fue visto por última vez en \(loc)."
        } else {
            return "Fue encontrado en \(loc)."
        }
    }

    private static func buildCTA(status: String) -> String {
        if status == "Perdido" {
            return "Si lo ves, repórtalo en la app para notificar a la comunidad de inmediato."
        } else {
            return "Si es tu mascota o conoces al dueño, contáctanos a través de la app."
        }
    }
}