//
//  ContentView.swift
//  PetApp
//

import SwiftUI

struct ContentView: View {
    @AppStorage("appThemeMode") private var themeModeRaw: String = AppThemeMode.system.rawValue

    private var themeMode: AppThemeMode {
        AppThemeMode(rawValue: themeModeRaw) ?? .system
    }

    var body: some View {
        AuthView()
            .preferredColorScheme(themeMode.colorScheme)
    }
}

#Preview {
    ContentView()
}
