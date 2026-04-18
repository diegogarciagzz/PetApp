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
    @State private var selectedPlace: PetPlace?

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
            .sheet(item: $selectedPlace) { place in
                PlaceDetailSheet(place: place)
                    .presentationDetents([.medium, .large])
            }
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
        Map(position: $cameraPosition, selection: $selectedPlace) {
            ForEach(filteredPlaces) { place in
                Annotation(place.name, coordinate: place.coordinate) {
                    Button {
                        selectedPlace = place
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: place.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                            )
                        )
                    } label: {
                        ZStack {
                            Circle()
                                .fill(AppColors.primary)
                                .frame(width: 40, height: 40)

                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                                .shadow(radius: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .tag(place)
            }
        }
        .mapStyle(.standard)
        .frame(height: 320)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var placesList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(filteredPlaces) { place in
                    Button {
                        selectedPlace = place
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

                            VStack(alignment: .leading, spacing: 6) {
                                Text(place.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppColors.textPrimary)

                                Text(place.category)
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)

                                HStack(spacing: 4) {
                                    ForEach(1...5, id: \.self) { star in
                                        Image(systemName: star <= Int(place.rating) ? "star.fill" : "star")
                                            .font(.caption)
                                            .foregroundStyle(AppColors.primary)
                                    }
                                }
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

// MARK: - Detail Sheet
struct PlaceDetailSheet: View {
    let place: PetPlace
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        AsyncImage(url: URL(string: place.photos.first ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(AppColors.card)
                                    .frame(height: 240)

                                Image(systemName: iconForCategory(place.category))
                                    .font(.system(size: 48))
                                    .foregroundStyle(AppColors.primary.opacity(0.5))
                            }
                        }
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 24))

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(place.name)
                                    .font(.title2.bold())
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer()
                            }

                            HStack {
                                Image(systemName: iconForCategory(place.category))
                                    .foregroundStyle(AppColors.primary)

                                Text(place.category)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppColors.textPrimary)

                                Spacer()
                            }

                            Text(place.address)
                                .font(.subheadline)
                                .foregroundStyle(AppColors.textSecondary)
                        }

                        HStack(spacing: 8) {
                            HStack(spacing: 2) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= Int(place.rating) ? "star.fill" : "star")
                                        .font(.title3)
                                        .foregroundStyle(AppColors.primary)
                                }
                            }

                            Text("\(place.rating, specifier: "%.1f") (\(place.reviewCount) opiniones)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppColors.textPrimary)

                            Spacer()
                        }

                        if !place.petTypes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Mascotas permitidas")
                                    .font(.headline)
                                    .foregroundStyle(AppColors.textPrimary)

                                HStack(spacing: 8) {
                                    ForEach(place.petTypes.prefix(4), id: \.self) { type in
                                        VStack(spacing: 4) {
                                            Text(type.emoji)
                                                .font(.system(size: 24))

                                            Text(type.rawValue)
                                                .font(.caption2)
                                                .foregroundStyle(AppColors.textPrimary)
                                        }
                                        .frame(width: 50)
                                    }

                                    if place.petTypes.count > 4 {
                                        Text("+\(place.petTypes.count - 4)")
                                            .font(.caption)
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Comentarios recientes")
                                .font(.headline)
                                .foregroundStyle(AppColors.textPrimary)

                            ForEach(place.comments.prefix(3)) { comment in
                                commentRow(comment)
                            }
                        }

                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationTitle(place.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.primary)
                }
            }
        }
    }

    private func commentRow(_ comment: PlaceComment) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(AppColors.primary.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppColors.primary)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.userName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    HStack(spacing: 1) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= comment.stars ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundStyle(AppColors.primary)
                        }
                    }
                }

                Text(comment.text)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)

                Text(comment.date)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(.vertical, 8)
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
