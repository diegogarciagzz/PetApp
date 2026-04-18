//
//  NuevaPublicacionView.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import SwiftUI
import PhotosUI

struct NuevaPublicacionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = NuevaPublicacionViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // Selector de foto
                        PhotosPicker(selection: $vm.imagenSeleccionada,
                                     matching: .images) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppColors.softBeige.opacity(0.7))
                                    .frame(height: 220)

                                if let imagen = vm.imagenPreview {
                                    Image(uiImage: imagen)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 220)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                } else {
                                    VStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 36))
                                            .foregroundStyle(AppColors.primary)
                                        Text("Agregar foto")
                                            .font(.subheadline)
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                }
                            }
                        }
                        .onChange(of: vm.imagenSeleccionada) { _, nuevo in
                            Task { await vm.cargarImagen(nuevo) }
                        }

                        // Título
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Título")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppColors.textSecondary)
                            TextField("Dale un título a tu post...", text: $vm.titulo)
                                .padding(12)
                                .background(AppColors.card)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Texto
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Descripción")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppColors.textSecondary)
                            TextField("¿Qué hizo tu mascota hoy?",
                                      text: $vm.texto,
                                      axis: .vertical)
                                .lineLimit(4...8)
                                .padding(12)
                                .background(AppColors.card)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Error
                        if let error = vm.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        // Botón publicar
                        Button {
                            Task { await vm.publicar() }
                        } label: {
                            HStack {
                                if vm.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Publicar")
                                        .font(.subheadline.weight(.semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(vm.puedePublicar ? AppColors.primary : AppColors.card)
                            .foregroundStyle(vm.puedePublicar ? .white : AppColors.textSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!vm.puedePublicar || vm.isLoading)
                    }
                    .padding(AppSpacing.screenPadding)
                }
            }
            .navigationTitle("Nueva publicación")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(AppColors.primary)
                }
            }
            .onChange(of: vm.publicacionExitosa) { _, exito in
                if exito { dismiss() }
            }
        }
    }
}
