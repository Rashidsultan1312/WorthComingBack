import Foundation

enum AppTab: Hashable {
    case map
    case add
    case journal
    case explore

    var title: String {
        switch self {
        case .map:
            return "Map"
        case .add:
            return "Add"
        case .journal:
            return "Journal"
        case .explore:
            return "Explore"
        }
    }

    var systemImage: String {
        switch self {
        case .map:
            return "map.fill"
        case .add:
            return "plus.circle.fill"
        case .journal:
            return "book.pages.fill"
        case .explore:
            return "sparkles"
        }
    }
}
