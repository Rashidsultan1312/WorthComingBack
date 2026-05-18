import Foundation

@MainActor
final class AddPlaceViewModel: ObservableObject {
    @Published var placeName = ""
    @Published var note = ""
    @Published var selectedIntent: ReturnIntent = .yes
    @Published var vibeEmoji = "✨"
    @Published var personalRating = 4
    @Published var selectedCoordinate: PlaceCoordinate?
    @Published var coordinateSourceText = "Waiting for location"

    private var hasPreparedInitialState = false

    var canSave: Bool {
        selectedCoordinate != nil && !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var coordinateText: String {
        selectedCoordinate?.shortLabel ?? "No location selected"
    }

    func prepareIfNeeded(pendingCoordinate: PlaceCoordinate?, currentLocation: PlaceCoordinate?) {
        guard !hasPreparedInitialState else { return }
        hasPreparedInitialState = true

        if let pendingCoordinate {
            applyPendingCoordinate(pendingCoordinate)
            return
        }

        if let currentLocation {
            selectedCoordinate = currentLocation
            coordinateSourceText = "Using current location"
        } else {
            coordinateSourceText = "Allow location or pin on map"
        }
    }

    func applyPendingCoordinate(_ coordinate: PlaceCoordinate) {
        selectedCoordinate = coordinate
        coordinateSourceText = "Pinned from map"
    }

    func updateCurrentLocation(_ coordinate: PlaceCoordinate?) {
        guard selectedCoordinate == nil, let coordinate else { return }
        selectedCoordinate = coordinate
        coordinateSourceText = "Using current location"
    }

    func save(in store: PlacesStore) -> Bool {
        guard canSave, let selectedCoordinate else { return false }

        store.addPlace(
            name: placeName,
            note: note,
            returnIntent: selectedIntent,
            vibeEmoji: vibeEmoji,
            coordinate: selectedCoordinate,
            personalRating: personalRating
        )

        note = ""
        placeName = ""
        selectedIntent = .yes
        vibeEmoji = "✨"
        personalRating = 4
        coordinateSourceText = "Saved. You can forget it now."
        return true
    }
}
