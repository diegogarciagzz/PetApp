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

struct PetPlace: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    let address: String
    let latitude: Double
    let longitude: Double
    let rating: Double
    let reviewCount: Int
    let photos: [String]
    let comments: [PlaceComment]
    let petTypes: [PetType]
    let isPetFriendly: Bool

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func == (lhs: PetPlace, rhs: PetPlace) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct PlaceComment: Identifiable, Hashable {
    let id = UUID()
    let userName: String
    let userAvatar: String
    let text: String
    let stars: Int
    let date: String
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

// MARK: - Pet con init normal e init para edición
struct Pet: Identifiable {
    let id: UUID
    let name: String
    let breed: String
    let age: String
    let type: PetType
    let emoji: String

    // Init normal (para MockData y nuevas mascotas)
    init(name: String, breed: String, age: String, type: PetType, emoji: String) {
        self.id = UUID()
        self.name = name
        self.breed = breed
        self.age = age
        self.type = type
        self.emoji = emoji
    }

    // Init con id override (para editar conservando el mismo id)
    init(id: UUID, name: String, breed: String, age: String, type: PetType, emoji: String) {
        self.id = id
        self.name = name
        self.breed = breed
        self.age = age
        self.type = type
        self.emoji = emoji
    }
}

enum PetType: String, CaseIterable, Identifiable, Hashable {
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
