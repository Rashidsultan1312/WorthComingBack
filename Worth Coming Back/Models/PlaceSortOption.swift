import Foundation

enum PlaceSortOption: String, CaseIterable, Identifiable {
    case newestFirst
    case mood
    case comeback

    var id: String { rawValue }

    var title: String {
        switch self {
        case .newestFirst:
            return "By Time"
        case .mood:
            return "By Mood"
        case .comeback:
            return "Come Back"
        }
    }
}
