//
//  PetImageValidator.swift
//  PetApp
//
//  Usa Vision framework (on-device) para verificar que una imagen
//  contenga una mascota antes de permitir publicar.
//

import Vision
import UIKit

enum PetImageValidator {

    // MARK: - Public API

    /// Devuelve `true` si la imagen contiene al menos una mascota reconocida.
    static func containsPet(_ image: UIImage) async -> Bool {
        guard let cg = image.cgImage else { return false }

        // 1. VNRecognizeAnimalsRequest — detecta perros y gatos con alta precisión
        if await detectWithAnimalRequest(cgImage: cg) { return true }

        // 2. VNClassifyImageRequest — cubre aves, reptiles, roedores y otros animales
        return await detectWithClassification(cgImage: cg)
    }

    // MARK: - Private helpers

    private static func detectWithAnimalRequest(cgImage: CGImage) async -> Bool {
        await withCheckedContinuation { continuation in
            let request = VNRecognizeAnimalsRequest { req, _ in
                let found = (req.results as? [VNRecognizedObjectObservation])?.isEmpty == false
                continuation.resume(returning: found)
            }
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }

    private static func detectWithClassification(cgImage: CGImage) async -> Bool {
        await withCheckedContinuation { continuation in
            let request = VNClassifyImageRequest { req, _ in
                let observations = req.results as? [VNClassificationObservation] ?? []
                let petKeywords: Set<String> = [
                    "dog", "cat", "bird", "animal", "pet", "reptile",
                    "hamster", "rabbit", "fish", "canine", "feline",
                    "rodent", "lizard", "snake", "turtle", "parrot",
                    "mammal", "puppy", "kitten", "poodle", "terrier",
                    "retriever", "bulldog", "husky", "corgi", "beagle",
                    "labrador", "chihuahua", "siamese", "persian",
                    "guinea", "ferret", "chinchilla", "iguana", "gecko"
                ]
                let found = observations.contains { obs in
                    obs.confidence > 0.15 &&
                    petKeywords.contains(where: { obs.identifier.lowercased().contains($0) })
                }
                continuation.resume(returning: found)
            }
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }
}
