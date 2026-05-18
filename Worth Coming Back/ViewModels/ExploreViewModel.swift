import Foundation

enum ExploreFilter: String, CaseIterable, Identifiable {
    case bestMonth
    case forgotten
    case all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bestMonth:
            return "Best This Month"
        case .forgotten:
            return "Forgotten"
        case .all:
            return "All Memories"
        }
    }
}

@MainActor
final class ExploreViewModel: ObservableObject {
    @Published var selectedFilter: ExploreFilter = .bestMonth

    func favoriteMoodText(from places: [Place]) -> String {
        let grouped = Dictionary(grouping: places, by: \.returnIntent)
        let top = grouped.max { $0.value.count < $1.value.count }?.key

        switch top {
        case .yes:
            return "You mostly save places that feel great."
        case .maybe:
            return "You often keep balanced, mixed-vibe spots."
        case .no:
            return "You are great at spotting places to avoid."
        case .none:
            return "Add a few places and your patterns will appear."
        }
    }

    func reminderText(from places: [Place]) -> String {
        let forgotten = places
            .filter { $0.returnIntent != .no }
            .filter { Calendar.current.dateComponents([.day], from: $0.createdAt, to: .now).day ?? 0 > 21 }

        guard !forgotten.isEmpty else {
            return "Your favorite spots are still fresh this month."
        }

        return "You have \(forgotten.count) good spots not visited recently."
    }

    func suggestedReturns(from places: [Place]) -> [Place] {
        places
            .filter { $0.returnIntent == .yes || $0.returnIntent == .maybe }
            .sorted { $0.createdAt < $1.createdAt }
            .prefix(3)
            .map { $0 }
    }

    func filteredPlaces(from places: [Place]) -> [Place] {
        switch selectedFilter {
        case .bestMonth:
            let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: .now)) ?? .now
            return places
                .filter { $0.returnIntent == .yes && $0.createdAt >= startOfMonth }
                .sorted { $0.createdAt > $1.createdAt }
        case .forgotten:
            return places
                .filter { $0.returnIntent != .no }
                .filter { Calendar.current.dateComponents([.day], from: $0.createdAt, to: .now).day ?? 0 > 21 }
                .sorted { $0.createdAt < $1.createdAt }
        case .all:
            return places.sorted { $0.createdAt > $1.createdAt }
        }
    }
}
