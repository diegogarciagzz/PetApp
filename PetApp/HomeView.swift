//
//  HomeView.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//


import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0

    private var filteredPosts: [Post] {
        if selectedTab == 0 {
            return MockData.posts
        } else {
            return MockData.posts.filter { $0.isFriendPost }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        segmentedControl

                        LazyVStack(spacing: 16) {
                            ForEach(filteredPosts) { post in
                                PostCardView(post: post)
                            }
                        }
                    }
                    .padding(AppSpacing.screenPadding)
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hola 👋")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)

                Text("Descubre mascotas")
                    .font(.title2.bold())
                    .foregroundStyle(AppColors.textPrimary)
            }

            Spacer()

            Image(systemName: "bell")
                .font(.title3)
                .foregroundStyle(AppColors.textPrimary)
                .padding(10)
                .background(AppColors.card)
                .clipShape(Circle())
        }
    }

    private var segmentedControl: some View {
        HStack(spacing: 10) {
            segmentButton(title: "Para ti", index: 0)
            segmentButton(title: "Siguiendo", index: 1)
        }
    }

    private func segmentButton(title: String, index: Int) -> some View {
        Button {
            selectedTab = index
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(selectedTab == index ? .white : AppColors.textPrimary)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(selectedTab == index ? AppColors.primary : AppColors.card)
                .clipShape(Capsule())
        }
    }
}

struct PostCardView: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(AppColors.softBeige)
                    .frame(width: 42, height: 42)
                    .overlay(
                        Image(systemName: "pawprint.fill")
                            .foregroundStyle(AppColors.primary)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.userName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)

                    Text(post.userHandle)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: "ellipsis")
                    .foregroundStyle(AppColors.textSecondary)
            }

            RoundedRectangle(cornerRadius: 18)
                .fill(AppColors.softBeige.opacity(0.7))
                .frame(height: 220)
                .overlay(
                    VStack {
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundStyle(AppColors.primary)

                        Text(post.imageName)
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                )

            Text(post.caption)
                .font(.subheadline)
                .foregroundStyle(AppColors.textPrimary)

            HStack(spacing: 18) {
                Label("\(post.likes)", systemImage: "heart")
                Label("\(post.comments)", systemImage: "message")
                Label("Guardar", systemImage: "bookmark")
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(AppColors.textSecondary)
        }
        .padding(14)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardCorner))
    }
}

#Preview {
    HomeView()
}