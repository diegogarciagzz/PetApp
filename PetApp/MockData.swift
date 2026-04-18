
//
//  MockData.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//
import Foundation

enum MockData {
    static let posts: [Post] = [
        Post(
            userName: "Sofía Ramírez",
            userHandle: "@sofiapaws",
            imageName: "dog1",
            caption: "Luna en su paseo favorito 🐶☀️",
            likes: 128,
            comments: 14,
            isFriendPost: true
        ),
        Post(
            userName: "Carlos Gómez",
            userHandle: "@carlospets",
            imageName: "cat1",
            caption: "Michi dormilón después de jugar toda la tarde 🐱",
            likes: 94,
            comments: 8,
            isFriendPost: false
        ),
        Post(
            userName: "Valentina Cruz",
            userHandle: "@valeandpets",
            imageName: "dog2",
            caption: "Primera visita al parque pet friendly del finde con mi tortuga 🐢✨",
            likes: 201,
            comments: 25,
            isFriendPost: true
        )
    ]

    static let places: [PetPlace] = [
        PetPlace(
            name: "Parque Rufino Tamayo",
            category: "Parque",
            address: "San Pedro Garza García",
            latitude: 25.6516,
            longitude: -100.3567
        ),
        PetPlace(
            name: "Paseo Santa Lucía",
            category: "Paseo",
            address: "Centro de Monterrey",
            latitude: 25.6747,
            longitude: -100.3090
        ),
        PetPlace(
            name: "Parque Tolteca",
            category: "Parque",
            address: "Guadalupe",
            latitude: 25.6762,
            longitude: -100.2443
        ),
        PetPlace(
            name: "Warehouse 42",
            category: "Café",
            address: "Barrio Antiguo",
            latitude: 25.6681,
            longitude: -100.3097
        ),
        PetPlace(
            name: "Mor House",
            category: "Café",
            address: "Del Valle, San Pedro",
            latitude: 25.6503,
            longitude: -100.3398
        )
    ]

    static let reports: [PetReport] = [
        PetReport(
            petName: "Max",
            type: "Perro",
            color: "Café",
            location: "Cumbres",
            hoursAgo: 3,
            details: "Perro mediano con collar azul.",
            matchScore: 92,
            status: "Perdido"
        ),
        PetReport(
            petName: "Nala",
            type: "Gato",
            color: "Blanco",
            location: "San Jerónimo",
            hoursAgo: 6,
            details: "Gata blanca con mancha gris en la oreja.",
            matchScore: 78,
            status: "Encontrado"
        ),
        PetReport(
            petName: "Rocky",
            type: "Perro",
            color: "Negro",
            location: "Contry",
            hoursAgo: 12,
            details: "Lomito grande, muy amigable.",
            matchScore: 64,
            status: "Perdido"
        ),
        PetReport(
            petName: "Pipo",
            type: "Hámster",
            color: "Dorado",
            location: "Cumbres Elite",
            hoursAgo: 2,
            details: "Hámster dorado con rabadilla blanca, escapó de su jaula.",
            matchScore: 85,
            status: "Perdido"
        )
    ]
    
    static let chats: [ChatPreview] = [
        ChatPreview(name: "Sofía", lastMessage: "Ya vi el reporte, lo comparto.", time: "10:24"),
        ChatPreview(name: "Rescate MTY", lastMessage: "¿Tienes otra foto de la mascota?", time: "Ayer"),
        ChatPreview(name: "Carlos", lastMessage: "Creo que lo vi por el parque.", time: "Ayer")
    ]
    
    static let messages: [String: [ChatMessage]] = [
        "Sofía": [
            ChatMessage(text: "Hola! Vi el reporte de tu perro 🐶", isFromMe: false, time: "10:20"),
            ChatMessage(text: "¿Cuándo lo perdiste?", isFromMe: false, time: "10:21"),
            ChatMessage(text: "Ayer en la noche por Cumbres 😢", isFromMe: true, time: "10:22"),
            ChatMessage(text: "Ya vi el reporte, lo comparto.", isFromMe: false, time: "10:24"),
        ],
        "Rescate MTY": [
            ChatMessage(text: "Recibimos tu reporte.", isFromMe: false, time: "Ayer"),
            ChatMessage(text: "¿Tienes otra foto de la mascota?", isFromMe: false, time: "Ayer"),
            ChatMessage(text: "Sí, te mando una.", isFromMe: true, time: "Ayer"),
        ],
        "Carlos": [
            ChatMessage(text: "Creo que lo vi por el parque.", isFromMe: false, time: "Ayer"),
            ChatMessage(text: "¿De qué color era su collar?", isFromMe: true, time: "Ayer"),
            ChatMessage(text: "Azul, creo.", isFromMe: false, time: "Ayer"),
        ]
    ]

    static let pets: [Pet] = [
        Pet(name: "Luna", breed: "Labrador Retriever", age: "2 años", type: .dog, emoji: PetType.dog.emoji),
        Pet(name: "Mimi", breed: "Siamés", age: "4 años", type: .cat, emoji: PetType.cat.emoji),
        Pet(name: "Tito", breed: "Orejas rojas", age: "3 años", type: .turtle, emoji: PetType.turtle.emoji),
        Pet(name: "Bunny", breed: "Holandés enano", age: "1 año", type: .rabbit, emoji: PetType.rabbit.emoji),
        Pet(name: "Pipo", breed: "Sirio dorado", age: "6 meses", type: .hamster, emoji: PetType.hamster.emoji),
        Pet(name: "Piolín", breed: "Lovebird", age: "2 años", type: .bird, emoji: PetType.bird.emoji)
    ]

    static let user = UserProfile(
        name: "Andrea Torres",
        username: "@andreat",
        bio: "Pet lover de Monterrey. Comparto lugares pet friendly y ayudo a difundir reportes de mascotas perdidas. 🐶🐱🐢",
        city: "Monterrey, Nuevo León",
        petsCount: 6,
        postsCount: 12,
        reportsCount: 3
    )
}
