//
//  Theme.swift
//  PetApp
//
//  Colores adaptativos: cambian según light/dark mode.
//

import SwiftUI
import UIKit

enum AppColors {
    static let background = dynamic(
        light: UIColor(red: 248/255, green: 244/255, blue: 239/255, alpha: 1),
        dark:  UIColor(red:  22/255, green:  20/255, blue:  18/255, alpha: 1)
    )
    static let card = dynamic(
        light: UIColor(red: 255/255, green: 253/255, blue: 249/255, alpha: 1),
        dark:  UIColor(red:  36/255, green:  33/255, blue:  30/255, alpha: 1)
    )
    static let primary = dynamic(
        light: UIColor(red: 229/255, green: 138/255, blue: 74/255, alpha: 1),
        dark:  UIColor(red: 240/255, green: 155/255, blue: 95/255, alpha: 1)
    )
    static let primaryDark = dynamic(
        light: UIColor(red: 217/255, green: 115/255, blue: 50/255, alpha: 1),
        dark:  UIColor(red: 199/255, green: 105/255, blue: 45/255, alpha: 1)
    )
    static let textPrimary = dynamic(
        light: UIColor(red: 62/255, green: 44/255, blue: 35/255, alpha: 1),
        dark:  UIColor(red: 238/255, green: 230/255, blue: 220/255, alpha: 1)
    )
    static let textSecondary = dynamic(
        light: UIColor(red: 138/255, green: 122/255, blue: 112/255, alpha: 1),
        dark:  UIColor(red: 170/255, green: 158/255, blue: 146/255, alpha: 1)
    )
    static let softBeige = dynamic(
        light: UIColor(red: 234/255, green: 216/255, blue: 200/255, alpha: 1),
        dark:  UIColor(red:  58/255, green:  50/255, blue:  42/255, alpha: 1)
    )

    private static func dynamic(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        })
    }
}

enum AppSpacing {
    static let screenPadding: CGFloat = 16
    static let cardCorner: CGFloat = 20
}

/// Preferencia global de modo oscuro.
/// `nil` = seguir al sistema. `true` = forzar oscuro. `false` = forzar claro.
enum AppThemeMode: String {
    case system, light, dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}
