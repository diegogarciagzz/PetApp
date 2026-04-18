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
            caption: "Michi dormilón después de jugar toda la tarde.",
            likes: 94,
            comments: 8,
            isFriendPost: false
        ),
        Post(
            userName: "Valentina Cruz",
            userHandle: "@valeandpets",
            imageName: "dog2",
            caption: "Primera visita al parque pet friendly del finde ✨",
            likes: 201,
            comments: 25,
            isFriendPost: true
        )
    ]

    static let places: [PetPlace] = [
        PetPlace(name: "Parque Rufino Tamayo", category: "Parque", address: "San Pedro"),
        PetPlace(name: "Pet Coffee MX", category: "Café", address: "Monterrey"),
        PetPlace(name: "VetCare Center", category: "Veterinaria", address: "Cumbres")
    ]

    static let reports: [PetReport] = [
        PetReport(
            petName: "Max",
            type: "Perro",
            color: "Café",
            location: "Cumbres",
            hoursAgo: 3,
            details: "Perro mediano con collar azul.",
            matchScore: 92
        ),
        PetReport(
            petName: "Nala",
            type: "Gato",
            color: "Blanco",
            location: "San Jerónimo",
            hoursAgo: 6,
            details: "Gata blanca con mancha gris en la oreja.",
            matchScore: 78
        ),
        PetReport(
            petName: "Rocky",
            type: "Perro",
            color: "Negro",
            location: "Contry",
            hoursAgo: 12,
            details: "Lomito grande, muy amigable.",
            matchScore: 64
        )
    ]

    static let chats: [ChatPreview] = [
        ChatPreview(name: "Sofía", lastMessage: "Ya vi el reporte, lo comparto.", time: "10:24"),
        ChatPreview(name: "Rescate MTY", lastMessage: "¿Tienes otra foto de la mascota?", time: "Ayer"),
        ChatPreview(name: "Carlos", lastMessage: "Creo que lo vi por el parque.", time: "Ayer")
    ]

    static let user = UserProfile(
        name: "Andrea Torres",
        username: "@andreat",
        petsCount: 2,
        postsCount: 12,
        reportsCount: 3
    )
}