//
//  NuevoReporteView.swift
//  PetApp
//
//  Crear un reporte de mascota perdida.
//

import SwiftUI
import PhotosUI

struct NuevoReporteView: View {
    @Environment(\.dismiss) private var dismiss
    var onCreado: () -> Void = {}

    @State private var selectedPetId: UUID?
    @State private var descripcion = ""
    @State private var ubicacionTexto = ""
    @State private var latitud: String = ""
    @State private var longitud: String = ""

    @State private var imagenItem: PhotosPickerItem?
    @State private var imagenPreview: UIImage?

    @State private var cargando = false
    @State private var error: String?
    @State private var exito = false

    private var mascotas: [MascotaDB] { UserSession.shared.myPets }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        mascotaPicker

                        // Foto de referencia
                        PhotosPicker(selection: $imagenItem, matching: .images) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppColors.softBeige.opacity(0.7))
                                    .frame(height: 180)
                                if let img = imagenPreview {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 180)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                } else {
                                    VStack(spacing: 6) {
                                        Image(systemName: "camera.fill")
                                            .font(.title)
                                            .foregroundStyle(AppColors.primary)
                                        Text("Foto de referencia (opcional)")
                                            .font(.caption)
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                }
                            }
                        }
                        .onChange(of: imagenItem) { _, nuevo in
                            Task { await cargarImagen(nuevo) }
                        }

                        campo(titulo: "Descripción", texto: $descripcion, multiline: true)
                        campo(titulo: "Última ubicación conocida", texto: $ubicacionTexto)

                        HStack(spacing: 10) {
                            campo(titulo: "Latitud", texto: $latitud, keyboard: .numbersAndPunctuation)
                            campo(titulo: "Longitud", texto: $longitud, keyboard: .numbersAndPunctuation)
                        }

                        if let e = error {
                            Text(e).font(.caption).foregroundStyle(.red)
                        }

                        Button {
                            Task { await crear() }
                        } label: {
                            HStack {
                                if cargando { ProgressView().tint(.white) }
                                else { Text("Crear reporte").font(.headline) }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(puedeGuardar ? AppColors.primary : AppColors.textSecondary.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(!puedeGuardar || cargando)
                        .buttonStyle(.plain)
                    }
                    .padding(AppSpacing.screenPadding)
                }
            }
            .navigationTitle("Nuevo reporte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(AppColors.primary)
                }
            }
            .onAppear {
                if selectedPetId == nil { selectedPetId = mascotas.first?.id }
            }
            .onChange(of: exito) { _, e in if e { dismiss() } }
        }
    }

    private var puedeGuardar: Bool { selectedPetId != nil }

    private var mascotaPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("¿Qué mascota se perdió?")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)

            if mascotas.isEmpty {
                Text("Aún no tienes mascotas registradas.")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(mascotas) { m in
                            Button {
                                selectedPetId = m.id
                            } label: {
                                HStack(spacing: 6) {
                                    Text(PetType(rawValue: m.tipoAnimal)?.emoji ?? "🐾")
                                    Text(m.nombre)
                                        .font(.subheadline.weight(.semibold))
                                }
                                .foregroundStyle(selectedPetId == m.id ? .white : AppColors.textPrimary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(selectedPetId == m.id ? AppColors.primary : AppColors.card)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func campo(titulo: String, texto: Binding<String>, multiline: Bool = false, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titulo).font(.caption.weight(.semibold)).foregroundStyle(AppColors.textSecondary)
            if multiline {
                TextField(titulo, text: texto, axis: .vertical)
                    .lineLimit(3...6)
                    .keyboardType(keyboard)
                    .padding(12)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                TextField(titulo, text: texto)
                    .keyboardType(keyboard)
                    .padding(12)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func cargarImagen(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let img = UIImage(data: data) {
            imagenPreview = img
        }
    }

    private func crear() async {
        guard let mascotaId = selectedPetId,
              let userId = UserSession.shared.currentUserId else {
            error = "No hay sesión activa."
            return
        }
        cargando = true
        error = nil
        do {
            var urlFoto: String? = nil
            if let img = imagenPreview {
                urlFoto = try await StorageManager.shared.subirImagen(
                    img,
                    bucket: StorageManager.Bucket.reportes,
                    carpeta: mascotaId.uuidString
                )
            }
            try await ReportService.shared.crearReporte(
                idMascota: mascotaId,
                idUsuario: userId,
                descripcion: descripcion.isEmpty ? nil : descripcion,
                fotoReferencia: urlFoto,
                latitud: Double(latitud),
                longitud: Double(longitud),
                ubicacionDesc: ubicacionTexto.isEmpty ? nil : ubicacionTexto,
                estado: "activo"
            )
            onCreado()
            exito = true
        } catch {
            self.error = "No se pudo crear: \(error.localizedDescription)"
        }
        cargando = false
    }
}
