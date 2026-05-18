import SwiftUI

struct JournalView: View {
    @EnvironmentObject private var store: PlacesStore
    @StateObject private var viewModel = JournalViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        sortPicker

                        if sortedPlaces.isEmpty {
                            emptyState
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(sortedPlaces) { place in
                                    PlaceSummaryCard(place: place)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 96)
                }
            }
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var sortedPlaces: [Place] {
        viewModel.sortedPlaces(from: store.places)
    }

    private var sortPicker: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Sort")
                    .font(.headline)

                Picker("Sort places", selection: $viewModel.selectedSort) {
                    ForEach(PlaceSortOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var emptyState: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("No places yet")
                    .font(.headline)
                Text("Add your first memory and this becomes your geographic diary.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView()
            .environmentObject(PlacesStore.preview)
    }
}
