//
//  ReportesViewModel.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import Foundation
import Combine
import Supabase

@MainActor
class ReportesViewModel: ObservableObject {
    @Published var reportes: [MascotaPerdida] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseManager.shared.client

    func cargarReportes() async {
        isLoading = true
        errorMessage = nil
        do {
            reportes = try await client
                .from("vista_mascotas_perdidas")
                .select()
                .execute()
                .value
            print("✅ Reportes cargados: \(reportes.count)")
        } catch {
            print("❌ Error: \(error)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
