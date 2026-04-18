//
//  ReportesView.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//
import SwiftUI

struct ReportesView: View {
    @StateObject private var vm = ReportesViewModel()
    @State private var mostrarNuevo = false
    @State private var seleccion: MascotaPerdida?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AppColors.background.ignoresSafeArea()

                Group {
                    if vm.isLoading && vm.reportes.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if vm.reportes.isEmpty {
                        ContentUnavailableView(
                            "Sin reportes activos",
                            systemImage: "magnifyingglass",
                            description: Text("Toca el botón + para crear uno.")
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(vm.reportes) { reporte in
                                    Button {
                                        seleccion = reporte
                                    } label: {
                                        ReporteCardView(reporte: reporte)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(AppSpacing.screenPadding)
                            .padding(.bottom, 100)
                        }
                    }
                }

                Button {
                    mostrarNuevo = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text("Nuevo")
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(AppColors.primary)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                .accessibilityLabel("Nuevo reporte")
            }
            .navigationTitle("Desaparecidos")
            .navigationBarTitleDisplayMode(.large)
            .task { await vm.cargarReportes() }
            .refreshable { await vm.cargarReportes() }
            .sheet(isPresented: $mostrarNuevo) {
                NuevoReporteView {
                    Task { await vm.cargarReportes() }
                }
                .presentationDetents([.large])
            }
            .sheet(item: $seleccion) { rep in
                ReporteDetailView(reporte: rep) {
                    Task { await vm.cargarReportes() }
                }
                .presentationDetents([.large])
            }
        }
    }
}

struct ReporteCardView: View {
    let reporte: MascotaPerdida

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 12) {
                RemoteOrDataImage(urlString: reporte.fotoMascota ?? reporte.fotoReferencia,
                                  placeholderSystem: "pawprint.fill",
                                  cornerRadius: 28)
                .frame(width: 56, height: 56)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("SE BUSCA")
                            .font(.caption2.weight(.heavy))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.red)
                            .clipShape(Capsule())

                        if let raza = reporte.raza {
                            Text(raza)
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }

                    Text(reporte.nombreMascota)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppColors.textPrimary)

                    HStack(spacing: 4) {
                        if let edad = reporte.edad {
                            Text("\(edad) años")
                        }
                        if let sexo = reporte.sexo {
                            Text("·")
                            Text(sexo == "M" ? "Macho" : "Hembra")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()
            }

            if let desc = reporte.descripcion {
                Text(desc)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(3)
            }

            if let lugar = reporte.ultimaUbicacionDesc {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(Color.red)
                    Text("Última vez visto en: \(lugar)")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Divider()

            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "eye.fill")
                        .foregroundStyle(AppColors.primary)
                    Text("\(reporte.totalAvistamientos) avistamiento\(reporte.totalAvistamientos == 1 ? "" : "s")")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .foregroundStyle(AppColors.textSecondary)
                    Text("Dueño: \(reporte.nombreDueno)")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                Text(reporte.fechaReporte.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(14)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardCorner))
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cardCorner)
                .stroke(Color.red.opacity(0.25), lineWidth: 1)
        )
    }
}

#Preview {
    ReportesView()
}
