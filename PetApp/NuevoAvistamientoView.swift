//
//  NuevoAvistamientoView.swift
//  PetApp
//

import SwiftUI
import PhotosUI

struct NuevoAvistamientoView: View {
    let idReporte: UUID
    var onCreado: () -> Void = {}

    @Environment(\.dismiss) private var dismiss

    @State private var descripcionLugar = ""
    @State private var notas = ""
    @State private var latitud = ""
    @State private var longitud = ""
    @State private var imagenItem: PhotosPickerItem?
    @State private var imagenPreview: UIImage?
    @State private var cargando = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        PhotosPicker(selection: $imagenItem, matching: .images) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppColors.softBeige.opacity(0.7))
                                    .frame(height: 150)
                                if let img = imagenPreview {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                } else {
                                    VStack(spacing: 4) {
                                        Image(systemName: "camera.fill")
                                            .font(.title)
                                            .foregroundStyle(AppColors.primary)
                                        Text("Foto (opcional)")
                                            .font(.caption)
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                }
                            }
                        }
                        .onChange(of: imagenItem) { _, item in
                            Task {
                                if let data = try? await item?.loadTransferable(type: Data.self),
                                   let img = UIImage(data: data) {
                                    imagenPreview = img
                                }
                            }
                        }

                        campo(titulo: "Lugar / Referencia", texto: $descripcionLugar)
                        campo(titulo: "Notas", texto: $notas, multiline: true)

                        HStack(spacing: 10) {
                            campo(titulo: "Latitud", texto: $latitud, keyboard: .numbersAndPunctuation)
                            campo(titulo: "Longitud", texto: $longitud, keyboard: .numbersAndPunctuation)
                        }

                        if let e = error {
                            Text(e).font(.caption).foregroundStyle(.red)
                        }

                        Button {
                            Task { await enviar() }
                        } label: {
                            HStack {
                                if cargando { ProgressView().tint(.white) }
                                else { Text("Enviar avistamiento").font(.headline) }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                        .disabled(cargando)
                    }
                    .padding(AppSpacing.screenPadding)
                }
            }
            .navigationTitle("Nuevo avistamiento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(AppColors.primary)
                }
            }
        }
    }

    private func campo(titulo: String, texto: Binding<String>, multiline: Bool = false, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titulo).font(.caption.weight(.semibold)).foregroundStyle(AppColors.textSecondary)
            if multiline {
                TextField(titulo, text: texto, axis: .vertical)
                    .lineLimit(3...5)
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

    private func enviar() async {
        guard let uid = UserSession.shared.currentUserId else {
            error = "Necesitas iniciar sesión."
            return
        }
        cargando = true
        error = nil
        do {
            var urlFoto: String? = nil
            if let img = imagenPreview {
                urlFoto = try await StorageManager.shared.subirImagen(
                    img,
                    bucket: StorageManager.Bucket.avistamientos,
                    carpeta: idReporte.uuidString
                )
            }
            try await ReportService.shared.agregarAvistamiento(
                idReporte: idReporte,
                idUsuario: uid,
                latitud: Double(latitud),
                longitud: Double(longitud),
                descripcionLugar: descripcionLugar.isEmpty ? nil : descripcionLugar,
                notas: notas.isEmpty ? nil : notas,
                fotoAvistamiento: urlFoto
            )
            onCreado()
            dismiss()
        } catch {
            self.error = "No se pudo enviar: \(error.localizedDescription)"
        }
        cargando = false
    }
}
