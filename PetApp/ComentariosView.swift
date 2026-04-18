//
//  ComentariosView.swift
//  PetApp
//
//  Sheet para ver y publicar comentarios de una publicación.
//

import SwiftUI

struct ComentariosView: View {
    let post: FeedPost
    var onComentarioNuevo: () -> Void = {}

    @Environment(\.dismiss) private var dismiss

    @State private var comentarios: [ComentarioConAutor] = []
    @State private var texto: String = ""
    @State private var cargando = false
    @State private var enviando = false
    @State private var error: String?

    private var mascotaActualId: UUID? { UserSession.shared.activePetId }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 10) {
                            RemoteOrDataImage(
                                urlString: post.fotoMascota,
                                placeholderSystem: "pawprint.fill",
                                cornerRadius: 18
                            )
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())

                            Text(post.nombreMascota)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppColors.textPrimary)

                            Spacer()
                        }

                        if let t = post.titulo, !t.isEmpty {
                            Text(t)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppColors.textPrimary)
                        }

                        if let tx = post.texto, !tx.isEmpty {
                            Text(tx)
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                                .lineLimit(3)
                        }
                    }
                    .padding()
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.top, 8)

                    if cargando && comentarios.isEmpty {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if comentarios.isEmpty {
                        Spacer()
                        ContentUnavailableView(
                            "Sin comentarios",
                            systemImage: "bubble.left",
                            description: Text("Sé el primero en comentar.")
                        )
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 10) {
                                ForEach(comentarios) { c in
                                    comentarioRow(c)
                                }
                            }
                            .padding(.horizontal, AppSpacing.screenPadding)
                            .padding(.top, 10)
                        }
                    }

                    if let error = error {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal, AppSpacing.screenPadding)
                    }

                    HStack(spacing: 10) {
                        TextField("Escribe un comentario...", text: $texto, axis: .vertical)
                            .lineLimit(1...4)
                            .padding(10)
                            .background(AppColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                        Button {
                            Task { await publicar() }
                        } label: {
                            if enviando {
                                ProgressView().tint(AppColors.primary)
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .foregroundStyle(.white)
                                    .padding(12)
                                    .background(puedeEnviar ? AppColors.primary : AppColors.textSecondary.opacity(0.4))
                                    .clipShape(Circle())
                            }
                        }
                        .disabled(!puedeEnviar || enviando)
                        .buttonStyle(.plain)
                    }
                    .padding(AppSpacing.screenPadding)
                    .background(AppColors.background.opacity(0.95))
                }
            }
            .navigationTitle("Comentarios")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(AppColors.primary)
                }
            }
            .task { await cargar() }
        }
    }

    private var puedeEnviar: Bool {
        !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && mascotaActualId != nil
    }

    private func comentarioRow(_ c: ComentarioConAutor) -> some View {
        HStack(alignment: .top, spacing: 10) {
            RemoteOrDataImage(
                urlString: c.fotoMascota,
                placeholderSystem: "pawprint.fill",
                cornerRadius: 16
            )
            .frame(width: 32, height: 32)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(c.nombreMascota ?? "Mascota")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)

                    Text(c.fechaComentario.formatted(.relative(presentation: .named)))
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Text(c.texto)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textPrimary)
            }

            Spacer()
        }
        .padding(10)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func cargar() async {
        cargando = true
        error = nil

        do {
            comentarios = try await SocialService.shared.comentarios(publicacion: post.id)
        } catch {
            self.error = "No se pudieron cargar los comentarios."
        }

        cargando = false
    }

    private func publicar() async {
        guard let mascota = mascotaActualId else {
            error = "Necesitas una mascota para comentar."
            return
        }

        let contenido = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        enviando = true
        error = nil

        do {
            try await SocialService.shared.publicarComentario(
                publicacion: post.id,
                mascota: mascota,
                texto: contenido
            )
            texto = ""
            onComentarioNuevo()
            await cargar()
        } catch {
            self.error = "No se pudo publicar: \(error.localizedDescription)"
        }

        enviando = false
    }
}