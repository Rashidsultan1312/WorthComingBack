import SwiftUI

struct PlaceSummaryCard: View {
    let place: Place

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(place.name)
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Text(place.createdAt.mediumDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(place.vibeEmoji)
                        .font(.system(size: 30))
                }

                Text(place.note)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Circle()
                        .fill(place.returnIntent.color)
                        .frame(width: 9, height: 9)
                    Text(place.returnIntent.mapLabel)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    StarRatingDisplayView(rating: place.personalRating)
                    Spacer()
                    Text(place.coordinate.shortLabel)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
