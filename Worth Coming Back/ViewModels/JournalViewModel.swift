import Foundation

@MainActor
final class JournalViewModel: ObservableObject {
    @Published var selectedSort: PlaceSortOption = .newestFirst

    func sortedPlaces(from places: [Place]) -> [Place] {
        switch selectedSort {
        case .newestFirst:
            return places.sorted { $0.createdAt > $1.createdAt }
        case .mood:
            return places.sorted {
                if $0.returnIntent.sortingRank == $1.returnIntent.sortingRank {
                    return $0.createdAt > $1.createdAt
                }
                return $0.returnIntent.sortingRank < $1.returnIntent.sortingRank
            }
        case .comeback:
            return places.sorted {
                if $0.returnIntent.sortingRank == $1.returnIntent.sortingRank {
                    return $0.createdAt < $1.createdAt
                }
                return $0.returnIntent.sortingRank < $1.returnIntent.sortingRank
            }
        }
    }
}
