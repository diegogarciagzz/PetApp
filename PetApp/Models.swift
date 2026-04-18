//
//  Models.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//
import SwiftUI
import CoreLocation

struct Post: Identifiable {
    let id = UUID()
    let userName: String
    let userHandle: String
    let imageName: String
    let caption: String
    let likes: Int
    let comments: Int
    let isFriendPost: Bool
}

struct PetPlace: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let address: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct PetReport: Identifiable {
    let id = UUID()
    let petName: String
    let type: String
    let color: String
    let location: String
    let hoursAgo: Int
    let details: String
    let matchScore: Int
    let status: String
}

struct ChatPreview: Identifiable {
    let id = UUID()
    let name: String
    let lastMessage: String
    let time: String
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromMe: Bool
    let time: String
}

struct UserProfile {
    let name: String
    let username: String
    let bio: String
    let city: String
    let petsCount: Int
    let postsCount: Int
    let reportsCount: Int
}

struct Pet: Identifiable {
    let id = UUID()
    let name: String
    let breed: String
    let age: String
    let type: PetType  // Cambiado a enum para soportar múltiples tipos
    let emoji: String
}

enum PetType: String, CaseIterable, Identifiable {
    case dog = "Perro"
    case cat = "Gato"
    case turtle = "Tortuga"
    case rabbit = "Conejo"
    case hamster = "Hámster"
    case bird = "Pájaro"
    case other = "Otro"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .dog: return "🐶"
        case .cat: return "🐱"
        case .turtle: return "🐢"
        case .rabbit: return "🐰"
        case .hamster: return "🐹"
        case .bird: return "🐦"
        case .other: return "🐾"
        }
    }
}
