//
//  SupabaseManager.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://fpklsnsinnpnrcfhyiso.supabase.co")!,
            supabaseKey: "sb_publishable_RP5cQkXKuHb7g6ogDKkCSg_vgYvfpFe"
        )
    }
}
