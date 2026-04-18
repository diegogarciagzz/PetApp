//
//  NuevaPublicacionView.swift
//  PetApp
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

                        // MARK: Selector de foto
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
                                        Text("Agregar foto de tu mascota")
                                            .font(.subheadline)
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                }

                                // Spinner durante validación IA
                                if vm.isValidatingImage {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.black.opacity(0.45))
                                        .frame(height: 220)
                                    VStack(spacing: 10) {
                                        ProgressView()
                                            .tint(.white)
                                            .scaleEffect(1.2)
                                        Text("Verificando mascota con IA...")
                                            .font(.caption.weight(.medium))
                                            .foregroundStyle(.white)
                                    }
                                }

                                // Badge de validación exitosa
                                if vm.imageValidated && !vm.isValidatingImage {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Label("Mascota detectada", systemImage: "checkmark.seal.fill")
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(Color.green.opacity(0.85))
                                                .clipShape(Capsule())
                                                .padding(10)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .onChange(of: vm.imagenSeleccionada) { _, nuevo in
                            Task { await vm.cargarImagen(nuevo) }
                        }

                        // MARK: Error de validación
                        if let error = vm.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.orange)
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                            .padding(12)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // MARK: Título
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Título")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppColors.textSecondary)
                            TextField("Dale un título a tu post...", text: $vm.titulo)
                                .padding(12)
                                .background(AppColors.card)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            // Sugerencias de título
                            if !vm.titleSuggestions.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "sparkles")
                                            .font(.caption)
                                            .foregroundStyle(AppColors.primary)
                                        Text("Sugerencias IA")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(AppColors.primary)
                                    }

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(vm.titleSuggestions, id: \.self) { suggestion in
                                                Button {
                                                    vm.titulo = suggestion
                                                } label: {
                                                    Text(suggestion)
                                                        .font(.caption)
                                                        .lineLimit(1)
                                                        .foregroundStyle(AppColors.textPrimary)
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 8)
                                                        .background(AppColors.softBeige)
                                                        .clipShape(Capsule())
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // MARK: Descripción
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

                            // Sugerencias de descripción
                            if !vm.descriptionSuggestions.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "sparkles")
                                            .font(.caption)
                                            .foregroundStyle(AppColors.primary)
                                        Text("Sugerencias IA")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(AppColors.primary)
                                    }

                                    VStack(spacing: 6) {
                                        ForEach(vm.descriptionSuggestions, id: \.self) { suggestion in
                                            Button {
                                                vm.texto = suggestion
                                            } label: {
                                                HStack {
                                                    Text(suggestion)
                                                        .font(.caption)
                                                        .foregroundStyle(AppColors.textPrimary)
                                                        .multilineTextAlignment(.leading)
                                                    Spacer()
                                                    Image(systemName: "plus.circle")
                                                        .font(.caption)
                                                        .foregroundStyle(AppColors.primary)
                                                }
                                                .padding(10)
                                                .background(AppColors.softBeige.opacity(0.6))
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }

                        // MARK: Botón publicar
                        Button {
                            Task { await vm.publicar() }
                        } label: {
                            HStack {
                                if vm.isLoading {
                                    ProgressView().tint(.white)
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
