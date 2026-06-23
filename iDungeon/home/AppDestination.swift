import SwiftUI

enum AppDestination: String, Hashable, CaseIterable, Identifiable {
    case dungeons
    case shop
    case stats
    case skills

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dungeons: "Dungeons"
        case .shop: "Shop"
        case .stats: "Stats"
        case .skills: "Skills"
        }
    }

    var subtitle: String {
        switch self {
        case .dungeons: "Raycast run"
        case .shop: "Gear vendor"
        case .stats: "Build readout"
        case .skills: "Combat tree"
        }
    }

    var symbol: String {
        switch self {
        case .dungeons: "building.columns.fill"
        case .shop: "bag.fill"
        case .stats: "chart.bar.fill"
        case .skills: "sparkles"
        }
    }

    var tint: Color {
        switch self {
        case .dungeons: Color(red: 0.38, green: 0.86, blue: 0.98)
        case .shop: Color(red: 0.99, green: 0.69, blue: 0.34)
        case .stats: Color(red: 0.53, green: 0.88, blue: 0.60)
        case .skills: Color(red: 1.0, green: 0.49, blue: 0.62)
        }
    }
}
