//
//  ReporteDetailView.swift
//  PetApp
//
//  Detalle de un reporte perdido con lista de avistamientos.
//

import SwiftUI
import MapKit

struct ReporteDetailView: View {
    let reporte: MascotaPerdida
    var onCambio: () -> Void = {}

    @Environment(\.dismiss) private var dismiss

    @State private var avistamientos: [AvistamientoDB] = []
    @State private var cargando = false
    @State private var error: String?
    @State private var nuevoAvistamiento = false
    @State private var confirmarResuelto = false

    private var esMiReporte: Bool {
        reporte.idDueno == UserSession.shared.currentUserId
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        encabezado
                        if reporte.ultimaLat != nil || reporte.ultimaLon != nil {
                            mapaUltimaUbicacion
                        }
                        Divider()
                        Text("Avistamientos (\(avistamientos.count))")
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)

                        if cargando && avistamientos.isEmpty {
                            ProgressView().frame(maxWidth: .infinity)
                        } else if avistamientos.isEmpty {
                            Text("Aún no hay avistamientos reportados.")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.textSecondary)
                                .padding(.vertical, 6)
                        } else {
                            ForEach(avistamientos) { a in
                                avistamientoCard(a)
                            }
                        }

                        if let e = error {
                            Text(e).font(.caption).foregroundStyle(.red)
                        }

                        if !esMiReporte {
                            Button {
                                nuevoAvistamiento = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "eye.fill")
                                    Text("Reportar avistamiento")
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColors.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button {
                                confirmarResuelto = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.seal.fill")
                                    Text("Marcar como resuelto")
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.green)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(AppSpacing.screenPadding)
                }
            }
            .navigationTitle(reporte.nombreMascota)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(AppColors.primary)
                }
            }
            .sheet(isPresented: $nuevoAvistamiento) {
                NuevoAvistamientoView(idReporte: reporte.id) {
                    Task { await cargar() }
                    onCambio()
                }
                .presentationDetents([.medium, .large])
            }
            .alert("¿Marcar como resuelto?", isPresented: $confirmarResuelto) {
                Button("Confirmar", role: .destructive) {
                    Task { await marcarResuelto() }
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Esto cerrará el reporte activo.")
            }
            .task { await cargar() }
        }
    }

    private var encabezado: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                RemoteOrDataImage(urlString: reporte.fotoMascota ?? reporte.fotoReferencia,
                                  placeholderSystem: "pawprint.fill",
                                  cornerRadius: 30)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(reporte.nombreMascota)
                        .font(.title3.bold())
                        .foregroundStyle(AppColors.textPrimary)
                    if let raza = reporte.raza {
                        Text(raza)
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Text("Dueño: \(reporte.nombreDueno)")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
            }
            if let desc = reporte.descripcion, !desc.isEmpty {
                Text(desc)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textPrimary)
            }
            if let lugar = reporte.ultimaUbicacionDesc {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill").foregroundStyle(.red)
                    Text(lugar).font(.caption).foregroundStyle(AppColors.textSecondary)
                }
            }
        }
        .padding()
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    @ViewBuilder
    private var mapaUltimaUbicacion: some View {
        if let lat = reporte.ultimaLat, let lon = reporte.ultimaLon {
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            Map(initialPosition: .region(MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))) {
                Marker("Última ubicación", coordinate: coord)
                    .tint(.red)
                ForEach(avistamientos) { a in
                    if let lat = a.latitud, let lon = a.longitud {
                        Marker(
                            a.descripcionLugar ?? "Avistamiento",
                            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        )
                        .tint(AppColors.primary)
                    }
                }
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func avistamientoCard(_ a: AvistamientoDB) -> some View {
        HStack(alignment: .top, spacing: 12) {
            RemoteOrDataImage(urlString: a.fotoAvistamiento, placeholderSystem: "eye.fill", cornerRadius: 12)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                if let lugar = a.descripcionLugar {
                    Text(lugar)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                }
                if let notas = a.notas {
                    Text(notas)
                        .font(.caption)
                        .foregroundStyle(AppColors.textPrimary)
                }
                Text(a.fechaAvistamiento.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
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
            avistamientos = try await ReportService.shared.avistamientos(reporte: reporte.id)
        } catch {
            self.error = "No se pudieron cargar avistamientos: \(error.localizedDescription)"
        }
        cargando = false
    }

    private func marcarResuelto() async {
        do {
            try await ReportService.shared.marcarResuelto(reporte: reporte.id)
            onCambio()
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
