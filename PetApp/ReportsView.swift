//
//  ReportsView.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import SwiftUI

struct ReportsView: View {
    @State private var selectedSegment = 0
    @State private var showCreateReportSheet = false
    @State private var reports = MockData.reports

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        reportsHeader
                        reportSegmented

                        if selectedSegment == 0 {
                            reportsList
                        } else {
                            aiMatchesSection
                        }
                    }
                    .padding(AppSpacing.screenPadding)
                    .padding(.bottom, 90)
                }

                // MARK: - Botón flotante
                Button {
                    showCreateReportSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .accessibilityHidden(true)
                        Text("Nuevo")
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(AppColors.primary)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 6)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                .buttonStyle(.plain)
                .accessibilityLabel("Crear nuevo reporte de mascota")
            }
            .sheet(isPresented: $showCreateReportSheet) {
                CreateReportView { newReport in
                    reports.insert(newReport, at: 0)
                }
                .presentationDetents([.medium, .large])
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header
    private var reportsHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reportes")
                .font(.title2.bold())
                .foregroundStyle(AppColors.textPrimary)

            Text("Crea, revisa y conecta reportes perdidos o encontrados.")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    // MARK: - Segmented Control
    private var reportSegmented: some View {
        HStack(spacing: 10) {
            reportButton(title: "Ver reportes", index: 0)
            reportButton(title: "Coincidencias IA", index: 1)
        }
    }

    private func reportButton(title: String, index: Int) -> some View {
        Button {
            selectedSegment = index
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(selectedSegment == index ? .white : AppColors.textPrimary)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(selectedSegment == index ? AppColors.primary : AppColors.card)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(selectedSegment == index ? .isSelected : [])
    }

    // MARK: - Lista de reportes
    private var reportsList: some View {
        VStack(spacing: 14) {
            createReportInfoCard

            ForEach(reports) { report in
                ReportCardView(report: report)
            }
        }
    }

    private var createReportInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ayuda a la comunidad")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text("Publica una mascota perdida o encontrada para que otros usuarios puedan verla rápido.")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)

            Button {
                showCreateReportSheet = true
            } label: {
                Text("Crear reporte")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Crear nuevo reporte")
        }
        .padding()
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Sección IA
    private var aiMatchesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(AppColors.primary)
                        .accessibilityHidden(true)
                    Text("Coincidencias sugeridas")
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                }

                Text("La IA prioriza reportes relacionados por contexto: tiempo, ubicación, tipo y descripción.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }

            ForEach(reports.sorted(by: { $0.matchScore > $1.matchScore })) { report in
                AIMatchCardView(report: report)
            }
        }
    }
}

// MARK: - ReportCardView
struct ReportCardView: View {
    let report: PetReport

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(report.petName)
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Text(report.status)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(report.status == "Perdido" ? .white : AppColors.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(report.status == "Perdido" ? AppColors.primary : AppColors.softBeige)
                    .clipShape(Capsule())
            }

            Text("\(report.type) • \(report.color) • \(report.location)")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)

            Text(report.details)
                .font(.subheadline)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(3)

            Text("Hace \(report.hoursAgo) horas")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding()
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(report.status): \(report.petName), \(report.type) de color \(report.color) en \(report.location)")
    }
}

// MARK: - AIMatchCardView
struct AIMatchCardView: View {
    let report: PetReport

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(report.petName)
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)

                    Text("\(report.type) • \(report.location)")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("\(report.matchScore)%")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(matchColor(score: report.matchScore))
                        .clipShape(Circle())

                    Text("match")
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Text("Posible coincidencia por color, zona y tiempo de reporte.")
                .font(.subheadline)
                .foregroundStyle(AppColors.textPrimary)

            // Barra de confianza
            VStack(alignment: .leading, spacing: 4) {
                Text("Confianza IA")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.softBeige)
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(matchColor(score: report.matchScore))
                            .frame(width: geo.size.width * CGFloat(report.matchScore) / 100, height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding()
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(matchColor(score: report.matchScore).opacity(0.25), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Coincidencia \(report.matchScore)% para \(report.petName), \(report.type) en \(report.location)")
    }

    private func matchColor(score: Int) -> Color {
        if score >= 85 { return .green }
        if score >= 70 { return .orange }
        return .gray
    }
}

// MARK: - CreateReportView
struct CreateReportView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var petName = ""
    @State private var selectedType = "Perro"
    @State private var selectedStatus = "Perdido"
    @State private var color = ""
    @State private var location = ""
    @State private var details = ""

    // IA
    @State private var generatedDescription = ""
    @State private var isGenerating = false
    @State private var hasGenerated = false

    let onSave: (PetReport) -> Void
    let petTypes = ["Perro", "Gato"]
    let statuses = ["Perdido", "Encontrado"]

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        inputField(title: "Nombre de la mascota", text: $petName)
                        pickerCard(title: "Tipo", selection: $selectedType, options: petTypes)
                        pickerCard(title: "Estado", selection: $selectedStatus, options: statuses)
                        inputField(title: "Color", text: $color)
                        inputField(title: "Ubicación", text: $location)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Detalles")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppColors.textPrimary)

                            TextEditor(text: $details)
                                .frame(height: 100)
                                .padding(10)
                                .background(AppColors.card)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .accessibilityLabel("Campo de detalles adicionales")
                        }

                        // MARK: - Botón IA
                        Button {
                            generateWithAI()
                        } label: {
                            HStack(spacing: 10) {
                                if isGenerating {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(0.85)
                                } else {
                                    Image(systemName: "sparkles")
                                        .accessibilityHidden(true)
                                }
                                Text(isGenerating ? "Generando..." : "✨ Generar descripción con IA")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [AppColors.primary, AppColors.primary.opacity(0.75)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                        .disabled(isGenerating)
                        .accessibilityLabel("Generar descripción automática con inteligencia artificial")

                        // MARK: - Resultado IA
                        if hasGenerated && !generatedDescription.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 6) {
                                    Image(systemName: "sparkles")
                                        .foregroundStyle(AppColors.primary)
                                        .accessibilityHidden(true)
                                    Text("Descripción generada por IA")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(AppColors.primary)
                                }

                                Text(generatedDescription)
                                    .font(.subheadline)
                                    .foregroundStyle(AppColors.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .accessibilityLabel("Descripción generada: \(generatedDescription)")

                                Button {
                                    details = generatedDescription
                                } label: {
                                    Text("Usar esta descripción")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(AppColors.primary)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Usar descripción generada por IA en el campo de detalles")
                            }
                            .padding()
                            .background(AppColors.softBeige.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.primary.opacity(0.25), lineWidth: 1)
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // MARK: - Guardar
                        Button {
                            let newReport = PetReport(
                                petName: petName.isEmpty ? "Sin nombre" : petName,
                                type: selectedType,
                                color: color.isEmpty ? "No especificado" : color,
                                location: location.isEmpty ? "Ubicación pendiente" : location,
                                hoursAgo: 0,
                                details: details.isEmpty ? generatedDescription : details,
                                matchScore: Int.random(in: 55...95),
                                status: selectedStatus
                            )
                            onSave(newReport)
                            dismiss()
                        } label: {
                            Text("Guardar reporte")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppColors.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 8)
                        .accessibilityLabel("Guardar reporte de mascota")
                    }
                    .padding(AppSpacing.screenPadding)
                    .animation(.easeInOut(duration: 0.3), value: hasGenerated)
                }
            }
            .navigationTitle("Nuevo reporte")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.primary)
                }
            }
        }
    }

    // MARK: - Lógica IA
    private func generateWithAI() {
        isGenerating = true
        hasGenerated = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            generatedDescription = PetDescriptionAI.generateDescription(
                name: petName,
                type: selectedType,
                color: color,
                location: location,
                details: details,
                status: selectedStatus
            )
            isGenerating = false
            hasGenerated = true
        }
    }

    // MARK: - Componentes
    private func inputField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)

            TextField(title, text: text)
                .padding()
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .accessibilityLabel(title)
        }
    }

    private func pickerCard(title: String, selection: Binding<String>, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)

            Picker(title, selection: selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Selector de \(title.lowercased())")
        }
    }
}

#Preview {
    ReportsView()
}
