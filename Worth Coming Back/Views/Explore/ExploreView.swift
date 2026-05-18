import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var store: PlacesStore
    @StateObject private var viewModel = ExploreViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        insightsCard
                        suggestionsCard
                        filterCard
                        filteredList
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 96)
                }
            }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var insightsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Your pattern")
                    .font(.headline)
                Text(viewModel.favoriteMoodText(from: store.places))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Divider()

                Text(viewModel.reminderText(from: store.places))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
            }
        }
    }

    private var suggestionsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("3 places worth revisiting")
                    .font(.headline)

                let suggestions = viewModel.suggestedReturns(from: store.places)
                if suggestions.isEmpty {
                    Text("Once you save positive memories, this list appears here.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(suggestions) { place in
                        HStack(spacing: 10) {
                            Text(place.vibeEmoji)
                            Text(place.name)
                                .font(.subheadline.weight(.medium))
                            Spacer()
                            Text(place.createdAt.relativeDate)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private var filterCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Quick reflection")
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(ExploreFilter.allCases) { filter in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.selectedFilter = filter
                                }
                            } label: {
                                Text(filter.title)
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        viewModel.selectedFilter == filter
                                        ? Color.blue
                                        : Color.white.opacity(0.6),
                                        in: Capsule()
                                    )
                                    .foregroundStyle(viewModel.selectedFilter == filter ? Color.white : Color.primary)
                            }
                        }
                    }
                }
            }
        }
    }

    private var filteredList: some View {
        VStack(spacing: 10) {
            let places = viewModel.filteredPlaces(from: store.places)

            if places.isEmpty {
                GlassCard {
                    Text("No places for this filter yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ForEach(places) { place in
                    PlaceSummaryCard(place: place)
                }
            }
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
            .environmentObject(PlacesStore.preview)
    }
}
