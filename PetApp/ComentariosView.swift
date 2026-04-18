//
//  ComentariosView.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import SwiftUI

struct ComentariosView: View {
    let post: FeedPost
    @StateObject private var vm: ComentariosViewModel
    @State private var textoNuevo = ""
    @FocusState private var inputFocused: Bool
    @Environment(\.dismiss) private var dismiss

    init(post: FeedPost) {
        self.post = post
        _vm = StateObject(wrappedValue: ComentariosViewModel(idPublicacion: post.id))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header de la publicación
                    postResumen
                        .padding(AppSpacing.screenPadding)
                    
                    Divider().padding(.horizontal, AppSpacing.screenPadding)

                    // Lista de comentarios
                    if vm.isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if vm.comentarios.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 40))
                                .foregroundStyle(AppColors.textSecondary)
                            Text("Sé el primero en comentar")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        Spacer()
                    } else {
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(vm.comentarios) { comentario in
                                        ComentarioRowView(comentario: comentario)
                                            .id(comentario.id)
                                    }
                                }
                                .padding(AppSpacing.screenPadding)
                            }
                            .onChange(of: vm.comentarios.count) { _, _ in
                                if let last = vm.comentarios.last {
                                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                                }
                            }
                        }
                    }

                    // Input de nuevo comentario
                    inputBar
                }
            }
            .navigationTitle("Comentarios")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(AppColors.primary)
                }
            }
            .task { await vm.cargarComentarios() }
            .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
                Button("OK") { vm.errorMessage = nil }
            } message: {
                Text(vm.errorMessage ?? "")
            }
        }
    }

    // MARK: - Resumen del post arriba
    private var postResumen: some View {
        HStack(spacing: 10) {
            AsyncImage(url: URL(string: post.fotoMascota ?? "")) { phase in
                if case .success(let img) = phase {
                    img.resizable().scaledToFill()
                } else {
                    Circle().fill(AppColors.softBeige)
                        .overlay(Image(systemName: "pawprint.fill").foregroundStyle(AppColors.primary))
                }
            }
            .frame(width: 38, height: 38)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(post.nombreMascota)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                if let titulo = post.titulo {
                    Text(titulo)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            Label("\(vm.comentarios.count)", systemImage: "bubble.left.fill")
                .font(.caption.weight(.medium))
                .foregroundStyle(AppColors.primary)
        }
    }

    // MARK: - Barra de input
    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 10) {
                TextField("Escribe un comentario...", text: $textoNuevo, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .focused($inputFocused)

                Button {
                    let texto = textoNuevo.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !texto.isEmpty else { return }
                    textoNuevo = ""
                    inputFocused = false
                    Task { await vm.enviarComentario(texto: texto) }
                } label: {
                    ZStack {
                        Circle()
                            .fill(textoNuevo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                  ? AppColors.softBeige : AppColors.primary)
                            .frame(width: 40, height: 40)
                        if vm.isSending {
                            ProgressView().tint(.white).scaleEffect(0.7)
                        } else {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(
                                    textoNuevo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? AppColors.textSecondary : .white
                                )
                        }
                    }
                }
                .disabled(textoNuevo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isSending)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, 10)
            .background(AppColors.background)
        }
    }
}

// MARK: - Fila de comentario
struct ComentarioRowView: View {
    let comentario: Comentario

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            AsyncImage(url: URL(string: comentario.fotoMascota ?? "")) { phase in
                if case .success(let img) = phase {
                    img.resizable().scaledToFill()
                } else {
                    Circle().fill(AppColors.softBeige)
                        .overlay(Image(systemName: "pawprint.fill")
                            .font(.caption)
                            .foregroundStyle(AppColors.primary))
                }
            }
            .frame(width: 34, height: 34)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(comentario.nombreMascota)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(comentario.fechaComentario.formatted(.relative(presentation: .named)))
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Text(comentario.texto)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(12)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
