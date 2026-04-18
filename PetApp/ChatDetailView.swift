//
//  ChatDetailView.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//


import SwiftUI
import Supabase

struct ImagenPreviewItem: Identifiable {
    let id = UUID()
    let urlStr: String
}

struct ChatDetailView: View {
    let conversacion: ConversacionPreview
    @StateObject private var vm: ChatDetailViewModel
    @State private var texto = ""
    @State private var showImagePicker = false
    @State private var imagenSeleccionada: UIImage? = nil
    @State private var showImagePreview: ImagenPreviewItem? = nil
    @FocusState private var inputFocused: Bool

    private let idYo: UUID

    init(conversacion: ConversacionPreview) {
        self.conversacion = conversacion
        let userId = SupabaseManager.shared.client.auth.currentUser?.id ?? UUID()
        self.idYo = userId
        _vm = StateObject(wrappedValue: ChatDetailViewModel(
            idConversacion: conversacion.id,
            idUsuarioActual: userId
        ))
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                mensajesScroll
                inputBar
            }
        }
        .navigationTitle(conversacion.nombreCompleto)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    AsyncImage(url: URL(string: conversacion.fotoOtro ?? "")) { phase in
                        if case .success(let img) = phase {
                            img.resizable().scaledToFill()
                        } else {
                            Circle().fill(AppColors.softBeige)
                                .overlay(
                                    Text(String(conversacion.nombreOtro.prefix(1)).uppercased())
                                        .font(.caption.bold())
                                        .foregroundStyle(AppColors.primary)
                                )
                        }
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())

                    Text(conversacion.nombreCompleto)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
        }
        .task { await vm.cargarMensajes() }
        .refreshable { await vm.cargarMensajes() }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $imagenSeleccionada)
        }
        .onChange(of: imagenSeleccionada) { _, img in
            guard let img else { return }
            Task { await vm.enviarImagen(img) }
        }
        .sheet(item: $showImagePreview) { item in
            ImagenFullscreenView(urlStr: item.urlStr)
        }
    }

    // MARK: - Lista mensajes
    private var mensajesScroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
                if vm.isLoading {
                    ProgressView().padding(.top, 40)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(vm.mensajes) { mensaje in
                            MensajeBubbleView(
                                mensaje: mensaje,
                                esPropio: mensaje.idUsuarioEmisor == idYo,
                                onTapImagen: { url in showImagePreview = ImagenPreviewItem(urlStr: url) }
                            )
                            .id(mensaje.id)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                }
            }
            .onChange(of: vm.mensajes.count) { _, _ in
                if let last = vm.mensajes.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                if let last = vm.mensajes.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }

    // MARK: - Input
    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 10) {
                // Botón imagen
                Button {
                    showImagePicker = true
                } label: {
                    Image(systemName: "photo")
                        .font(.title3)
                        .foregroundStyle(AppColors.primary)
                        .padding(10)
                        .background(AppColors.card)
                        .clipShape(Circle())
                }
                .disabled(vm.isSending)

                // TextField multilinea
                TextField("Mensaje...", text: $texto, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .focused($inputFocused)

                // Botón enviar
                Button {
                    let t = texto.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !t.isEmpty else { return }
                    texto = ""
                    inputFocused = false
                    Task { await vm.enviarTexto(t) }
                } label: {
                    ZStack {
                        Circle()
                            .fill(texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                  ? AppColors.softBeige : AppColors.primary)
                            .frame(width: 40, height: 40)
                        if vm.isSending {
                            ProgressView().tint(.white).scaleEffect(0.7)
                        } else {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(
                                    texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? AppColors.textSecondary : .white
                                )
                        }
                    }
                }
                .disabled(texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isSending)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(AppColors.background)
        }
    }
}

// MARK: - Burbuja de mensaje
struct MensajeBubbleView: View {
    let mensaje: Mensaje
    let esPropio: Bool
    let onTapImagen: (String) -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if esPropio { Spacer(minLength: 60) }

            VStack(alignment: esPropio ? .trailing : .leading, spacing: 4) {
                // Imagen adjunta
                if let imgUrl = mensaje.imagenUrl, let url = URL(string: imgUrl) {
                    AsyncImage(url: url) { phase in
                        if case .success(let img) = phase {
                            img.resizable().scaledToFill()
                                .frame(width: 200, height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .onTapGesture { onTapImagen(imgUrl) }
                        } else {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(AppColors.softBeige)
                                .frame(width: 200, height: 160)
                                .overlay(ProgressView())
                        }
                    }
                }

                // Texto
                if let contenido = mensaje.contenido, !contenido.isEmpty {
                    Text(contenido)
                        .font(.subheadline)
                        .foregroundStyle(esPropio ? .white : AppColors.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(esPropio ? AppColors.primary : AppColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }

                // Hora + seen
                HStack(spacing: 4) {
                    Text(mensaje.fechaEnvio.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)

                    if esPropio {
                        Image(systemName: mensaje.leido ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.caption2)
                            .foregroundStyle(mensaje.leido ? AppColors.primary : AppColors.textSecondary)
                    }
                }
            }

            if !esPropio { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Imagen fullscreen
struct ImagenFullscreenView: View {
    let urlStr: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            if let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    if case .success(let img) = phase {
                        img.resizable().scaledToFit()
                    } else {
                        ProgressView().tint(.white)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white)
                    .padding()
            }
        }
    }
}


