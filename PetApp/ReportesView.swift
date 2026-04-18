//
//  ReportesView.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//
import SwiftUI

struct ReportesView: View {
    @StateObject private var vm = ReportesViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                Group {
                    if vm.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if vm.reportes.isEmpty {
                        ContentUnavailableView(
                            "Sin reportes activos",
                            systemImage: "magnifyingglass",
                            description: Text("No hay mascotas perdidas reportadas.")
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(vm.reportes) { reporte in
                                    ReporteCardView(reporte: reporte)
                                }
                            }
                            .padding(AppSpacing.screenPadding)
                        }
                    }
                }
            }
            .navigationTitle("Desaparecidos")
            .navigationBarTitleDisplayMode(.large)
            .task { await vm.cargarReportes() }
            .refreshable { await vm.cargarReportes() }
        }
    }
}

struct ReporteCardView: View {
    let reporte: MascotaPerdida

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Badge + foto
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: reporte.fotoMascota ?? "")) { phase in
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

            // Descripción
            if let desc = reporte.descripcion {
                Text(desc)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(3)
            }

            // Última ubicación
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

            // Footer
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
