import SwiftUI

struct MapHomeView: View {
    @EnvironmentObject private var store: PlacesStore
    let onQuickAdd: (PlaceCoordinate) -> Void

    @State private var selectedPlace: Place?
    @State private var detailPlace: Place?

    var body: some View {
        ZStack {
            MemoryMapView(
                places: store.places,
                selectedPlace: $selectedPlace,
                onQuickAdd: onQuickAdd,
                onPlaceTap: { place in
                    detailPlace = place
                }
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                topPanel
                Spacer()
                bottomPanel
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 88)
        }
        .sheet(item: $detailPlace) { place in
            PlaceDetailView(placeID: place.id)
                .environmentObject(store)
        }
    }

    private var topPanel: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Your Memory Map")
                    .font(.system(size: 21, weight: .bold))

                Text("Long press anywhere to drop a point and remember why it mattered.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Triple tap also works for quick add.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 14) {
                    legendItem(color: ReturnIntent.yes.color, title: "Loved")
                    legendItem(color: ReturnIntent.maybe.color, title: "Okay")
                    legendItem(color: ReturnIntent.no.color, title: "Avoid")
                }
            }
        }
    }

    private var bottomPanel: some View {
        Group {
            if let selectedPlace {
                PlaceSummaryCard(place: selectedPlace)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                GlassCard {
                    HStack(spacing: 10) {
                        Image(systemName: "hand.tap.fill")
                            .foregroundStyle(Color.blue)
                        Text("Tap a pin to open details. Triple tap map to add.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.85), value: selectedPlace?.id)
    }

    private func legendItem(color: Color, title: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }
}

struct MapHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MapHomeView(onQuickAdd: { _ in })
            .environmentObject(PlacesStore.preview)
    }
}
