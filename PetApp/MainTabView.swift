//
//  MainTabView.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//


import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            MapView()
                .tabItem {
                    Label("Mapa", systemImage: "map.fill")
                }

            ReportesView()
                .tabItem {
                    Label("Reportes", systemImage: "exclamationmark.bubble.fill")
                }

            ChatsView()
                .tabItem {
                    Label("Chats", systemImage: "message.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person.crop.circle.fill")
                }
        }
        .tint(AppColors.primary)
    }
}

#Preview {
    MainTabView()
}
