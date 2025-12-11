//
//  Color.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 20/11/2025.
//

import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
    static let launchTheme = LaunchColorTheme()
}

struct ColorTheme {
    let accent = Color("AccentColor")
    let background = Color("BackgroundColor")
    let infoRowBackground = Color("InfoRowBackgroundColor")
    let green = Color("GreenColor")
    let red = Color("RedColor")
    let secondaryText = Color("SecondaryTextColor")
}

struct LaunchColorTheme {
    let launchBackground = Color("LaunchBackgroundColor")
    let launchAccent = Color("LaunchAccentColor")
}
