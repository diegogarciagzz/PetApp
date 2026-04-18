//
//  ChatsView.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import SwiftUI

struct ChatsView: View {
    @StateObject private var vm = ChatsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                if vm.isLoading {
                    ProgressView()
                } else if vm.conversaciones.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 48))
                            .foregroundStyle(AppColors.textSecondary)
                        Text("Sin conversaciones aún")
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)
                        Text("Cuando conectes con otro dueño, tu chat aparecerá aquí.")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(vm.conversaciones) { conv in
                                NavigationLink {
                                    ChatDetailView(conversacion: conv)
                                } label: {
                                    ConversacionRowView(conv: conv)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(AppSpacing.screenPadding)
                    }
                    .refreshable { await vm.cargarConversaciones() }
                }
            }
            .navigationTitle("Mensajes")
            .navigationBarTitleDisplayMode(.large)
            .task { await vm.cargarConversaciones() }
        }
    }
}

// MARK: - Fila de conversación
struct ConversacionRowView: View {
    let conv: ConversacionPreview
    private let hayNoLeidos: Bool

    init(conv: ConversacionPreview) {
        self.conv = conv
        self.hayNoLeidos = conv.mensajesNoLeidos > 0
    }

    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: conv.fotoOtro ?? "")) { phase in
                    if case .success(let img) = phase {
                        img.resizable().scaledToFill()
                    } else {
                        Circle().fill(AppColors.softBeige)
                            .overlay(
                                Text(String(conv.nombreOtro.prefix(1)).uppercased())
                                    .font(.headline.bold())
                                    .foregroundStyle(AppColors.primary)
                            )
                    }
                }
                .frame(width: 52, height: 52)
                .clipShape(Circle())

                // Badge de no leídos
                if hayNoLeidos {
                    ZStack {
                        Circle().fill(AppColors.primary)
                            .frame(width: 20, height: 20)
                        Text("\(min(conv.mensajesNoLeidos, 99))")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .offset(x: 4, y: 4)
                }
            }

            // Contenido
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conv.nombreCompleto)
                        .font(hayNoLeidos ? .subheadline.weight(.bold) : .subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    if let fecha = conv.fechaUltimoMensaje {
                        Text(fecha.formatted(.relative(presentation: .named)))
                            .font(.caption2)
                            .foregroundStyle(hayNoLeidos ? AppColors.primary : AppColors.textSecondary)
                    }
                }

                // Último mensaje
                Group {
                    if conv.ultimoMensaje == nil && conv.ultimoMensajeImagen != nil {
                        Label("Imagen", systemImage: "photo")
                    } else {
                        Text(conv.ultimoMensaje ?? "Sin mensajes")
                    }
                }
                .font(hayNoLeidos ? .caption.weight(.semibold) : .caption)
                .foregroundStyle(hayNoLeidos ? AppColors.textPrimary : AppColors.textSecondary)
                .lineLimit(1)
            }
        }
        .padding(12)
        .background(
            hayNoLeidos
            ? AppColors.card.opacity(1.0)
            : AppColors.card
        )
        .overlay(
            hayNoLeidos
            ? RoundedRectangle(cornerRadius: 18)
                .stroke(AppColors.primary.opacity(0.25), lineWidth: 1)
            : nil
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
