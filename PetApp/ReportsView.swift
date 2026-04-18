import SwiftUI

struct ReportsView: View {
    @State private var selectedSegment = 0

    var body: some View {
        NavigationStack {
            ZStack {
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
                }
            }
            .navigationBarHidden(true)
        }
    }

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
    }

    private var reportsList: some View {
        VStack(spacing: 14) {
            createReportCard

            ForEach(MockData.reports) { report in
                ReportCardView(report: report)
            }
        }
    }

    private var createReportCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Crear nuevo reporte")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text("Publica una mascota perdida o encontrada para que la comunidad pueda ayudarte.")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)

            Button {
            } label: {
                Text("Crear reporte")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding()
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var aiMatchesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Coincidencias sugeridas")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text("La IA prioriza reportes relacionados por contexto: tiempo, ubicación, tipo y descripción.")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)

            ForEach(MockData.reports.sorted(by: { $0.matchScore > $1.matchScore })) { report in
                AIMatchCardView(report: report)
            }
        }
    }
}

struct ReportCardView: View {
    let report: PetReport

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(report.petName)
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Text("\(report.hoursAgo)h")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.softBeige.opacity(0.7))
                    .clipShape(Capsule())
            }

            Text("\(report.type) • \(report.color) • \(report.location)")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)

            Text(report.details)
                .font(.subheadline)
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding()
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

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

                Text("\(report.matchScore)%")
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(matchColor(score: report.matchScore))
                    .clipShape(Circle())
            }

            Text("Posible coincidencia por color, zona y tiempo de reporte.")
                .font(.subheadline)
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding()
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func matchColor(score: Int) -> Color {
        if score >= 85 { return .green }
        if score >= 70 { return .orange }
        return .gray
    }
}

#Preview {
    ReportsView()
}