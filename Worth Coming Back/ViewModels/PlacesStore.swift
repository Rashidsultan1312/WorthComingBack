import Foundation

@MainActor
final class PlacesStore: ObservableObject {
    @Published private(set) var places: [Place] = [] {
        didSet { persistPlaces() }
    }

    @Published var pendingCoordinate: PlaceCoordinate?

    private let usePersistence: Bool
    private let storageKey = "worth_coming_back_places"

    init(usePersistence: Bool = true) {
        self.usePersistence = usePersistence
        if usePersistence {
            loadPlacesAsync()
        } else {
            places = Self.samplePlaces
        }
    }

    func addPlace(
        name: String,
        note: String,
        returnIntent: ReturnIntent,
        vibeEmoji: String,
        coordinate: PlaceCoordinate,
        personalRating: Int?
    ) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeVibe = vibeEmoji.trimmingCharacters(in: .whitespacesAndNewlines)

        let place = Place(
            name: trimmedName.isEmpty ? "Memory Spot" : trimmedName,
            note: trimmedNote,
            returnIntent: returnIntent,
            vibeEmoji: safeVibe.isEmpty ? "✨" : safeVibe,
            coordinate: coordinate,
            personalRating: personalRating
        )

        places.insert(place, at: 0)
    }

    func updatePlace(
        id: UUID,
        note: String,
        returnIntent: ReturnIntent,
        personalRating: Int?,
        photoData: Data?
    ) {
        guard let index = places.firstIndex(where: { $0.id == id }) else { return }
        places[index].note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        places[index].returnIntent = returnIntent
        places[index].personalRating = personalRating
        places[index].photoData = photoData
    }

    func place(with id: UUID) -> Place? {
        places.first(where: { $0.id == id })
    }

    func prepareQuickAdd(at coordinate: PlaceCoordinate) {
        pendingCoordinate = coordinate
    }

    func clearPendingCoordinate() {
        pendingCoordinate = nil
    }

    private func loadPlacesAsync() {
        let storageKey = storageKey

        Task {
            let loadedPlaces = await Task.detached(priority: .userInitiated) { () -> [Place] in
                if
                    let data = UserDefaults.standard.data(forKey: storageKey),
                    let decodedPlaces = try? JSONDecoder().decode([Place].self, from: data),
                    !decodedPlaces.isEmpty
                {
                    return decodedPlaces.sorted { $0.createdAt > $1.createdAt }
                }

                return Self.samplePlaces
            }.value

            self.places = loadedPlaces
        }
    }

    private func persistPlaces() {
        guard usePersistence else { return }
        guard let encoded = try? JSONEncoder().encode(places) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }
}

extension PlacesStore {
    static var preview: PlacesStore {
        PlacesStore(usePersistence: false)
    }

    nonisolated static var samplePlaces: [Place] {
        [
            Place(
                name: "Sunset Pier",
                note: "Quiet walk and perfect orange sky.",
                returnIntent: .yes,
                vibeEmoji: "🌅",
                coordinate: PlaceCoordinate(latitude: 55.0332, longitude: 82.9226),
                createdAt: .now.addingTimeInterval(-86_400 * 4),
                personalRating: 5
            ),
            Place(
                name: "Coffee Bench",
                note: "Good chat, average coffee, nice mood.",
                returnIntent: .maybe,
                vibeEmoji: "☕️",
                coordinate: PlaceCoordinate(latitude: 55.0418, longitude: 82.9344),
                createdAt: .now.addingTimeInterval(-86_400 * 12),
                personalRating: 3
            ),
            Place(
                name: "Crowded Square",
                note: "Too noisy and zero comfort.",
                returnIntent: .no,
                vibeEmoji: "😵‍💫",
                coordinate: PlaceCoordinate(latitude: 55.0269, longitude: 82.9204),
                createdAt: .now.addingTimeInterval(-86_400 * 26),
                personalRating: 1
            )
        ]
    }
}
