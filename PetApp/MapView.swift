//
//  MapView.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//
import SwiftUI
import MapKit

struct MapView: View {
    @State private var selectedCategory = "Todos"
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.67, longitude: -100.31),
            span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
        )
    )

    private let categories = ["Todos", "Parque", "Café", "Paseo"]

    private var filteredPlaces: [PetPlace] {
        if selectedCategory == "Todos" {
            return MockData.places
        } else {
            return MockData.places.filter { $0.category == selectedCategory }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    header
                    categoryFilters
                    mapSection
                    placesList
                }
                .padding(AppSpacing.screenPadding)
            }
            .navigationTitle("Mapa")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Lugares pet friendly")
                .font(.title2.bold())
                .foregroundStyle(AppColors.textPrimary)

            Text("Explora espacios en Monterrey para salir con tu mascota.")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selectedCategory == category ? .white : AppColors.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(selectedCategory == category ? AppColors.primary : AppColors.card)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var mapSection: some View {
        Map(position: $cameraPosition) {
            ForEach(filteredPlaces) { place in
                Marker(place.name, coordinate: place.coordinate)
            }
        }
        .frame(height: 320)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var placesList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(filteredPlaces) { place in
                    Button {
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: place.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                            )
                        )
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(AppColors.softBeige)
                                    .frame(width: 52, height: 52)

                                Image(systemName: iconForCategory(place.category))
                                    .foregroundStyle(AppColors.primary)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(place.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppColors.textPrimary)

                                Text("\(place.category) • \(place.address)")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .padding()
                        .background(AppColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func iconForCategory(_ category: String) -> String {
        switch category {
        case "Parque":
            return "leaf.fill"
        case "Café":
            return "cup.and.saucer.fill"
        case "Paseo":
            return "figure.walk"
        default:
            return "mappin.circle.fill"
        }
    }
}

#Preview {
    MapView()
}
