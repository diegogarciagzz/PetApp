//
//  PetAppApp.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import SwiftUI
import Supabase

@main
struct PetAppApp: App {
    // Inicializa Supabase al arrancar la app
    init() {
        _ = SupabaseManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
