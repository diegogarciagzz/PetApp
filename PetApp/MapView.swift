import SwiftUI

struct MapView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(AppColors.softBeige.opacity(0.6))
                        .frame(height: 320)
                        .overlay(
                            VStack(spacing: 10) {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(AppColors.primary)

                                Text("Mapa pet friendly")
                                    .font(.headline)
                                    .foregroundStyle(AppColors.textPrimary)

                                Text("Aquí después conectamos MapKit")
                                    .font(.subheadline)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        )

                    VStack(spacing: 12) {
                        ForEach(MockData.places) { place in
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(AppColors.primary)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(place.name)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(AppColors.textPrimary)

                                    Text("\(place.category) • \(place.address)")
                                        .font(.caption)
                                        .foregroundStyle(AppColors.textSecondary)
                                }

                                Spacer()
                            }
                            .padding()
                            .background(AppColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                    }

                    Spacer()
                }
                .padding(AppSpacing.screenPadding)
            }
            .navigationTitle("Mapa")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MapView()
}