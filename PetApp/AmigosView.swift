//
//  AmigosView.swift
//  PetApp
//
//  Amigos entre mascotas: solicitudes pendientes, amigos, buscar y enviar.
//

import SwiftUI

struct AmigosView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var seccion = 0

    @State private var solicitudes: [AmistadDB] = []
    @State private var amigos: [AmistadDB] = []
    @State private var enviadas: [AmistadDB] = []
    @State private var infoMascotas: [UUID: MascotaDB] = [:]

    @State private var busqueda = ""
    @State private var resultados: [MascotaDB] = []
    @State private var cargandoBusqueda = false

    @State private var cargando = false
    @State private var error: String?
    @State private var mensajeInfo: String?

    private var mascotaActual: UUID? { UserSession.shared.activePetId }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 14) {
                    Picker("Sección", selection: $seccion) {
                        Text("Solicitudes").tag(0)
                        Text("Amigos").tag(1)
                        Text("Buscar").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.top, 8)

                    if let m = mensajeInfo {
                        Text(m)
                            .font(.caption)
                            .foregroundStyle(AppColors.primary)
                            .padding(.horizontal)
                    }
                    if let e = error {
                        Text(e)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }

                    ScrollView {
                        switch seccion {
                        case 0: solicitudesSection
                        case 1: amigosSection
                        default: busquedaSection
                        }
                    }
                }
            }
            .navigationTitle("Amigos")
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

    // MARK: - Solicitudes entrantes
    private var solicitudesSection: some View {
        VStack(spacing: 10) {
            if cargando && solicitudes.isEmpty {
                ProgressView().padding()
            } else if solicitudes.isEmpty {
                ContentUnavailableView(
                    "Sin solicitudes",
                    systemImage: "tray",
                    description: Text("Cuando alguien te mande solicitud aparecerá aquí.")
                )
                .padding(.top, 40)
            } else {
                ForEach(solicitudes) { s in
                    let otro = infoMascotas[s.idMascota1]
                    amistadCard(
                        nombre: otro?.nombre ?? "Mascota",
                        tipo: otro?.tipoAnimal,
                        foto: otro?.fotoPerfil,
                        trailing: {
                            AnyView(
                                HStack(spacing: 8) {
                                    Button {
                                        Task { await responder(s, aceptar: true) }
                                    } label: {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.white)
                                            .padding(10)
                                            .background(AppColors.primary)
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Aceptar solicitud")

                                    Button {
                                        Task { await responder(s, aceptar: false) }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .foregroundStyle(.red)
                                            .padding(10)
                                            .background(Color.red.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Rechazar solicitud")
                                }
                            )
                        }
                    )
                }
            }
        }
        .padding(AppSpacing.screenPadding)
    }

    // MARK: - Amigos
    private var amigosSection: some View {
        VStack(spacing: 10) {
            if cargando && amigos.isEmpty {
                ProgressView().padding()
            } else if amigos.isEmpty {
                ContentUnavailableView(
                    "Sin amigos aún",
                    systemImage: "person.2",
                    description: Text("Busca otras mascotas para enviar solicitud.")
                )
                .padding(.top, 40)
            } else {
                ForEach(amigos) { a in
                    let otroId = a.idMascota1 == mascotaActual ? a.idMascota2 : a.idMascota1
                    let info = infoMascotas[otroId]
                    amistadCard(
                        nombre: info?.nombre ?? "Mascota",
                        tipo: info?.tipoAnimal,
                        foto: info?.fotoPerfil,
                        trailing: {
                            AnyView(
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(AppColors.primary)
                            )
                        }
                    )
                }

                if !enviadas.isEmpty {
                    Text("Solicitudes enviadas")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 12)
                    ForEach(enviadas) { e in
                        let otro = infoMascotas[e.idMascota2]
                        amistadCard(
                            nombre: otro?.nombre ?? "Mascota",
                            tipo: otro?.tipoAnimal,
                            foto: otro?.fotoPerfil,
                            trailing: {
                                AnyView(
                                    Text("Pendiente")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(AppColors.textSecondary)
                                )
                            }
                        )
                    }
                }
            }
        }
        .padding(AppSpacing.screenPadding)
    }

    // MARK: - Buscar
    private var busquedaSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppColors.textSecondary)
                TextField("Buscar por nombre de mascota...", text: $busqueda)
                    .autocapitalization(.none)
                    .onSubmit { Task { await buscar() } }
                if !busqueda.isEmpty {
                    Button {
                        busqueda = ""
                        resultados = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .padding(12)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Button {
                Task { await buscar() }
            } label: {
                Text(cargandoBusqueda ? "Buscando..." : "Buscar")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .disabled(cargandoBusqueda || busqueda.trimmingCharacters(in: .whitespaces).isEmpty)

            if resultados.isEmpty && !cargandoBusqueda {
                Text("Escribe un nombre y toca buscar.")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.top, 20)
            } else {
                ForEach(resultados) { m in
                    amistadCard(
                        nombre: m.nombre,
                        tipo: m.tipoAnimal,
                        foto: m.fotoPerfil,
                        trailing: {
                            AnyView(
                                Button {
                                    Task { await enviarSolicitud(a: m) }
                                } label: {
                                    Text("Enviar")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(AppColors.primary)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            )
                        }
                    )
                }
            }
        }
        .padding(AppSpacing.screenPadding)
    }

    // MARK: - Row
    private func amistadCard(nombre: String, tipo: String?, foto: String?, trailing: () -> AnyView) -> some View {
        HStack(spacing: 12) {
            RemoteOrDataImage(urlString: foto, placeholderSystem: "pawprint.fill", cornerRadius: 24)
                .frame(width: 48, height: 48)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(nombre)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                if let t = tipo {
                    Text(t)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Spacer()
            trailing()
        }
        .padding(12)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Actions
    private func cargar() async {
        guard let m = mascotaActual else {
            error = "Necesitas registrar una mascota para ver amigos."
            return
        }
        cargando = true
        error = nil
        do {
            async let sols = SocialService.shared.solicitudesPendientes(mascota: m)
            async let amis = SocialService.shared.amigos(mascota: m)
            async let envs = SocialService.shared.enviados(mascota: m)

            solicitudes = try await sols
            amigos = try await amis
            enviadas = try await envs

            let ids = Set(
                solicitudes.flatMap { [$0.idMascota1, $0.idMascota2] } +
                amigos.flatMap { [$0.idMascota1, $0.idMascota2] } +
                enviadas.flatMap { [$0.idMascota1, $0.idMascota2] }
            ).subtracting([m])
            infoMascotas = try await SocialService.shared.mascotas(ids: Array(ids))
        } catch {
            self.error = "No se pudieron cargar: \(error.localizedDescription)"
        }
        cargando = false
    }

    private func responder(_ s: AmistadDB, aceptar: Bool) async {
        do {
            try await SocialService.shared.responderSolicitud(id: s.id, aceptar: aceptar)
            mensajeInfo = aceptar ? "Solicitud aceptada." : "Solicitud rechazada."
            await cargar()
        } catch {
            self.error = "Error: \(error.localizedDescription)"
        }
    }

    private func buscar() async {
        cargandoBusqueda = true
        error = nil
        do {
            resultados = try await SocialService.shared.buscarMascotas(
                query: busqueda,
                excluyendo: mascotaActual
            )
        } catch {
            self.error = "No se pudo buscar: \(error.localizedDescription)"
        }
        cargandoBusqueda = false
    }

    private func enviarSolicitud(a mascota: MascotaDB) async {
        guard let origen = mascotaActual else {
            error = "Necesitas una mascota para enviar solicitudes."
            return
        }
        do {
            try await SocialService.shared.enviarSolicitud(de: origen, a: mascota.id)
            mensajeInfo = "Solicitud enviada a \(mascota.nombre)."
            await cargar()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
