//
//  AmigosView.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import SwiftUI

struct AmigosView: View {
    let idMascota: UUID
    @StateObject private var vm: AmistadViewModel
    @State private var amistadAEliminar: Amistad?
    @State private var showEliminarAlert = false

    init(idMascota: UUID) {
        self.idMascota = idMascota
        _vm = StateObject(wrappedValue: AmistadViewModel(idMascota: idMascota))
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            if vm.isLoading {
                ProgressView()
            } else {
                List {
                    // Solicitudes pendientes
                    if !vm.solicitudesRecibidas.isEmpty {
                        Section {
                            ForEach(vm.solicitudesRecibidas) { s in
                                SolicitudRowView(
                                    amistad: s,
                                    miId: idMascota,
                                    onAceptar: { Task { await vm.aceptar(s) } },
                                    onRechazar: { Task { await vm.rechazar(s) } }
                                )
                            }
                        } header: {
                            Label("Solicitudes (\(vm.solicitudesRecibidas.count))",
                                  systemImage: "person.badge.clock")
                                .foregroundStyle(AppColors.primary)
                                .font(.subheadline.weight(.semibold))
                        }
                    }

                    // Amigos
                    Section {
                        if vm.amigos.isEmpty {
                            ContentUnavailableView(
                                "Sin amigos aún",
                                systemImage: "pawprint.fill",
                                description: Text("Agrega mascotas para conectar.")
                            )
                            .listRowBackground(Color.clear)
                        } else {
                            ForEach(vm.amigos) { a in
                                AmigoRowView(amistad: a, miId: idMascota)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            amistadAEliminar = a
                                            showEliminarAlert = true
                                        } label: {
                                            Label("Eliminar", systemImage: "person.badge.minus")
                                        }
                                    }
                            }
                        }
                    } header: {
                        Label("Amigos (\(vm.amigos.count))",
                              systemImage: "pawprint.circle")
                            .foregroundStyle(AppColors.primary)
                            .font(.subheadline.weight(.semibold))
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Amigos")
        .navigationBarTitleDisplayMode(.large)
        .task { await vm.cargar() }
        .refreshable { await vm.cargar() }
        .alert("¿Eliminar amistad?",
               isPresented: $showEliminarAlert,
               presenting: amistadAEliminar) { a in
            Button("Eliminar", role: .destructive) {
                Task { await vm.eliminar(a) }
            }
            Button("Cancelar", role: .cancel) {}
        } message: { a in
            Text("Ya no verás las publicaciones de \(a.nombreAmigo(miId: idMascota)).")
        }
    }
}

// MARK: - Amigo aceptado
struct AmigoRowView: View {
    let amistad: Amistad
    let miId: UUID

    var body: some View {
        HStack(spacing: 12) {
            MascotaAvatar(url: amistad.fotoAmigo(miId: miId))

            VStack(alignment: .leading, spacing: 3) {
                Text(amistad.nombreAmigo(miId: miId))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                if let tipo = amistad.tipoAmigo(miId: miId) {
                    Text(tipo)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Spacer()

            // Botón mensaje
            NavigationLink {
                // Aquí irá ChatDetailView cuando lo conectemos
                Text("Chat con \(amistad.nombreAmigo(miId: miId))")
            } label: {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(AppColors.primary)
                    .padding(9)
                    .background(AppColors.primary.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Solicitud pendiente
struct SolicitudRowView: View {
    let amistad: Amistad
    let miId: UUID
    let onAceptar: () -> Void
    let onRechazar: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            MascotaAvatar(url: amistad.fotoAmigo(miId: miId))

            VStack(alignment: .leading, spacing: 3) {
                Text(amistad.nombreAmigo(miId: miId))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                Text("Quiere ser tu amigo 🐾")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: onRechazar) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(9)
                        .background(AppColors.card)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Button(action: onAceptar) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(9)
                        .background(AppColors.primary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Avatar reutilizable
struct MascotaAvatar: View {
    let url: String?

    var body: some View {
        AsyncImage(url: URL(string: url ?? "")) { phase in
            switch phase {
            case .success(let img):
                img.resizable().scaledToFill()
            default:
                Circle()
                    .fill(AppColors.softBeige)
                    .overlay(
                        Image(systemName: "pawprint.fill")
                            .foregroundStyle(AppColors.primary)
                    )
            }
        }
        .frame(width: 46, height: 46)
        .clipShape(Circle())
    }
}
