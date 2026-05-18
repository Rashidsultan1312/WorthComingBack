import Foundation

struct Place: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var note: String
    var returnIntent: ReturnIntent
    var vibeEmoji: String
    var coordinate: PlaceCoordinate
    var createdAt: Date
    var personalRating: Int?
    var photoData: Data?

    init(
        id: UUID = UUID(),
        name: String,
        note: String,
        returnIntent: ReturnIntent,
        vibeEmoji: String,
        coordinate: PlaceCoordinate,
        createdAt: Date = .now,
        personalRating: Int? = nil,
        photoData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.note = note
        self.returnIntent = returnIntent
        self.vibeEmoji = vibeEmoji
        self.coordinate = coordinate
        self.createdAt = createdAt
        self.personalRating = personalRating
        self.photoData = photoData
    }
}
