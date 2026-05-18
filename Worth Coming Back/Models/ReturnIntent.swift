import SwiftUI
import UIKit

enum ReturnIntent: String, CaseIterable, Codable, Identifiable {
    case yes
    case maybe
    case no

    var id: String { rawValue }

    var title: String {
        switch self {
        case .yes:
            return "Yes"
        case .maybe:
            return "Maybe"
        case .no:
            return "No"
        }
    }

    var mapLabel: String {
        switch self {
        case .yes:
            return "Loved"
        case .maybe:
            return "Okay"
        case .no:
            return "Avoid"
        }
    }

    var color: Color {
        switch self {
        case .yes:
            return Color(red: 0.13, green: 0.48, blue: 0.98)
        case .maybe:
            return Color(red: 0.96, green: 0.73, blue: 0.12)
        case .no:
            return Color(red: 0.93, green: 0.29, blue: 0.33)
        }
    }

    var uiColor: UIColor {
        switch self {
        case .yes:
            return UIColor(red: 0.13, green: 0.48, blue: 0.98, alpha: 1)
        case .maybe:
            return UIColor(red: 0.96, green: 0.73, blue: 0.12, alpha: 1)
        case .no:
            return UIColor(red: 0.93, green: 0.29, blue: 0.33, alpha: 1)
        }
    }

    var sortingRank: Int {
        switch self {
        case .yes:
            return 0
        case .maybe:
            return 1
        case .no:
            return 2
        }
    }
}
