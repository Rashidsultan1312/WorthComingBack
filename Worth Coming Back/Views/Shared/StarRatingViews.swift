import SwiftUI

struct StarRatingInputView: View {
    @Binding var rating: Int
    var maxStars: Int = 5

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...maxStars, id: \.self) { index in
                Button {
                    rating = index
                } label: {
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundStyle(index <= rating ? Color.orange : Color.secondary.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct StarRatingDisplayView: View {
    let rating: Int?
    var maxStars: Int = 5

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxStars, id: \.self) { index in
                Image(systemName: index <= (rating ?? 0) ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundStyle(index <= (rating ?? 0) ? Color.orange : Color.secondary.opacity(0.4))
            }
        }
    }
}
