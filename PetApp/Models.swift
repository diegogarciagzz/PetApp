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
    let petsCount: Int
    let postsCount: Int
    let reportsCount: Int
}

struct Pet: Identifiable {
    let id = UUID()
    let name: String
    let breed: String
    let age: String
    let emoji: String
}
