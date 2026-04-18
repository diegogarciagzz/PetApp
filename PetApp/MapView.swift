//
//  MapView.swift
//  PetApp
//

import SwiftUI
import MapKit
import PhotosUI

// MARK: - MapView

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
                                    Text(String(format: "%.1f", place.rating))
                                        .font(.caption)
                                        .foregroundStyle(AppColors.textSecondary)
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
        case "Parque": return "leaf.fill"
        case "Café":   return "cup.and.saucer.fill"
        case "Paseo":  return "figure.walk"
        default:       return "mappin.circle.fill"
        }
    }
}

// MARK: - Place Detail Sheet

struct PlaceDetailSheet: View {
    let place: PetPlace
    @Environment(\.dismiss) private var dismiss

    // Local state so new comments/photos are reflected immediately
    @State private var localComments: [PlaceComment] = []
    @State private var showAddComment = false
    @State private var selectedPhotoIndex = 0

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        photoGallery
                        placeInfo
                        ratingRow
                        petTypesSection
                        commentsSection
                        Spacer(minLength: 80)
                    }
                    .padding()
                }

                // Floating "Agregar comentario" button
                VStack {
                    Spacer()
                    Button {
                        showAddComment = true
                    } label: {
                        Label("Comentar y puntuar", systemImage: "star.bubble.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: AppColors.primary.opacity(0.4), radius: 8, y: 4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            }
            .navigationTitle(place.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(AppColors.primary)
                }
            }
            .sheet(isPresented: $showAddComment) {
                AddCommentSheet(placeName: place.name) { newComment in
                    localComments.insert(newComment, at: 0)
                }
            }
        }
        .onAppear {
            localComments = place.comments
        }
    }

    // MARK: - Photo Gallery

    private var photoGallery: some View {
        VStack(spacing: 8) {
            TabView(selection: $selectedPhotoIndex) {
                ForEach(Array(place.photos.enumerated()), id: \.offset) { index, photo in
                    photoCell(urlString: photo)
                        .tag(index)
                }
                // Show user-contributed photos from new comments
                ForEach(Array(localComments.enumerated()), id: \.offset) { index, comment in
                    if let photoURL = comment.photoURL {
                        photoCell(urlString: photoURL)
                            .tag(place.photos.count + index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 24))

            // Thumbnail strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(place.photos.enumerated()), id: \.offset) { index, photo in
                        thumbnailCell(urlString: photo, index: index)
                    }
                    ForEach(Array(localComments.enumerated()), id: \.offset) { index, comment in
                        if let photoURL = comment.photoURL {
                            thumbnailCell(urlString: photoURL, index: place.photos.count + index)
                        }
                    }
                }
            }
        }
    }

    private func photoCell(urlString: String) -> some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .success(let img):
                img.resizable().scaledToFill()
            default:
                ZStack {
                    RoundedRectangle(cornerRadius: 24).fill(AppColors.card)
                    Image(systemName: iconForCategory(place.category))
                        .font(.system(size: 52))
                        .foregroundStyle(AppColors.primary.opacity(0.4))
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 240, maxHeight: 240)
        .clipped()
    }

    private func thumbnailCell(urlString: String, index: Int) -> some View {
        Button { selectedPhotoIndex = index } label: {
            AsyncImage(url: URL(string: urlString)) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                default:
                    ZStack {
                        Color(AppColors.card)
                        Image(systemName: iconForCategory(place.category))
                            .font(.caption)
                            .foregroundStyle(AppColors.primary.opacity(0.5))
                    }
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selectedPhotoIndex == index ? AppColors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Place Info

    private var placeInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
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
    }

    // MARK: - Rating row

    private var ratingRow: some View {
        HStack(spacing: 8) {
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= Int(averageRating) ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundStyle(AppColors.primary)
                }
            }
            Text(String(format: "%.1f", averageRating))
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
            Text("(\(totalReviews) opiniones)")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
        }
        .padding(12)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var averageRating: Double {
        guard !localComments.isEmpty else { return place.rating }
        let newAvg = Double(localComments.map(\.stars).reduce(0, +)) / Double(localComments.count)
        // Blend original rating with local ratings
        let totalWeight = Double(place.reviewCount) + Double(localComments.count)
        return (place.rating * Double(place.reviewCount) + newAvg * Double(localComments.count)) / totalWeight
    }

    private var totalReviews: Int {
        place.reviewCount + localComments.filter { $0.userName == "Tú" }.count
    }

    // MARK: - Pet types

    private var petTypesSection: some View {
        Group {
            if !place.petTypes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mascotas permitidas")
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(place.petTypes, id: \.self) { type in
                                VStack(spacing: 4) {
                                    Text(type.emoji)
                                        .font(.system(size: 26))
                                    Text(type.rawValue)
                                        .font(.caption2)
                                        .foregroundStyle(AppColors.textPrimary)
                                }
                                .frame(width: 54)
                                .padding(.vertical, 8)
                                .background(AppColors.card)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Comments

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Comentarios")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("\(localComments.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.primary)
                    .clipShape(Capsule())
            }

            if localComments.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 32))
                            .foregroundStyle(AppColors.primary.opacity(0.4))
                        Text("Sé el primero en comentar")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                ForEach(localComments) { comment in
                    commentRow(comment)
                    if comment.id != localComments.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(16)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func commentRow(_ comment: PlaceComment) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(AppColors.primary.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(comment.userName.prefix(1)))
                            .font(.subheadline.weight(.bold))
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

            // Photo attached to comment
            if let photoURL = comment.photoURL, !photoURL.isEmpty {
                AsyncImage(url: URL(string: photoURL)) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                            .frame(height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    default:
                        EmptyView()
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func iconForCategory(_ category: String) -> String {
        switch category {
        case "Parque": return "leaf.fill"
        case "Café":   return "cup.and.saucer.fill"
        case "Paseo":  return "figure.walk"
        default:       return "mappin.circle.fill"
        }
    }
}

// MARK: - Add Comment Sheet

struct AddCommentSheet: View {
    let placeName: String
    var onSubmit: (PlaceComment) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var commentText = ""
    @State private var selectedStars = 5
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoPreview: UIImage?
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // Star Rating
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Tu puntuación")
                                .font(.headline)
                                .foregroundStyle(AppColors.textPrimary)

                            HStack(spacing: 12) {
                                ForEach(1...5, id: \.self) { star in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedStars = star
                                        }
                                    } label: {
                                        Image(systemName: star <= selectedStars ? "star.fill" : "star")
                                            .font(.system(size: 36))
                                            .foregroundStyle(star <= selectedStars ? AppColors.primary : AppColors.textSecondary.opacity(0.4))
                                            .scaleEffect(star == selectedStars ? 1.15 : 1.0)
                                    }
                                    .buttonStyle(.plain)
                                }
                                Spacer()
                                Text(ratingLabel)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppColors.primary)
                            }
                            .padding(14)
                            .background(AppColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        // Comment text
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tu comentario")
                                .font(.headline)
                                .foregroundStyle(AppColors.textPrimary)

                            TextField("Cuéntanos tu experiencia en \(placeName)...",
                                      text: $commentText,
                                      axis: .vertical)
                                .lineLimit(4...8)
                                .padding(14)
                                .background(AppColors.card)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        // Photo picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Agregar foto (opcional)")
                                .font(.headline)
                                .foregroundStyle(AppColors.textPrimary)

                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                if let preview = photoPreview {
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: preview)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 160)
                                            .clipShape(RoundedRectangle(cornerRadius: 14))

                                        Button {
                                            photoPreview = nil
                                            selectedPhoto = nil
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.title3)
                                                .foregroundStyle(.white)
                                                .padding(8)
                                        }
                                    }
                                } else {
                                    HStack(spacing: 10) {
                                        Image(systemName: "photo.badge.plus")
                                            .font(.title2)
                                            .foregroundStyle(AppColors.primary)
                                        Text("Seleccionar foto del lugar")
                                            .font(.subheadline)
                                            .foregroundStyle(AppColors.textSecondary)
                                        Spacer()
                                    }
                                    .padding(16)
                                    .background(AppColors.card)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(AppColors.primary.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                    )
                                }
                            }
                            .onChange(of: selectedPhoto) { _, item in
                                Task {
                                    if let data = try? await item?.loadTransferable(type: Data.self),
                                       let img = UIImage(data: data) {
                                        photoPreview = img
                                    }
                                }
                            }
                        }

                        // Submit button
                        Button {
                            submitComment()
                        } label: {
                            Group {
                                if isSubmitting {
                                    ProgressView().tint(.white)
                                } else {
                                    Label("Publicar comentario", systemImage: "checkmark.circle.fill")
                                        .font(.subheadline.weight(.semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(canSubmit ? AppColors.primary : AppColors.card)
                            .foregroundStyle(canSubmit ? .white : AppColors.textSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!canSubmit || isSubmitting)
                    }
                    .padding(AppSpacing.screenPadding)
                }
            }
            .navigationTitle("Comentar lugar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(AppColors.primary)
                }
            }
        }
    }

    private var canSubmit: Bool {
        !commentText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var ratingLabel: String {
        switch selectedStars {
        case 1: return "Muy malo"
        case 2: return "Malo"
        case 3: return "Regular"
        case 4: return "Bueno"
        case 5: return "Excelente"
        default: return ""
        }
    }

    private func submitComment() {
        isSubmitting = true

        // Convert photo to data URL if selected (local-only, no backend for places yet)
        var photoURL: String? = nil
        if let img = photoPreview,
           let data = img.jpegData(compressionQuality: 0.6) {
            photoURL = "data:image/jpeg;base64,\(data.base64EncodedString())"
        }

        let userName = UserSession.shared.currentUser.map { "\($0.nombre)" } ?? "Tú"
        let newComment = PlaceComment(
            userName: userName,
            userAvatar: "",
            text: commentText.trimmingCharacters(in: .whitespacesAndNewlines),
            stars: selectedStars,
            date: "Ahora",
            photoURL: photoURL
        )

        onSubmit(newComment)
        isSubmitting = false
        dismiss()
    }
}

#Preview {
    MapView()
}
