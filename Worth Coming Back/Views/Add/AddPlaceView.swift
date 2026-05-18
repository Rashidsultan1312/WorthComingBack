import SwiftUI

struct AddPlaceView: View {
    @EnvironmentObject private var store: PlacesStore
    @Binding var selectedTab: AppTab

    @StateObject private var viewModel = AddPlaceViewModel()
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                GeometryReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            locationCard
                            memoryCard
                            returnIntentCard
                            ratingCard
                            vibeCard
                            saveButton
                        }
                        .frame(width: proxy.size.width - 32)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                        .padding(.bottom, 100)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Save Moment")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            locationManager.requestIfNeeded()
            viewModel.prepareIfNeeded(
                pendingCoordinate: store.pendingCoordinate,
                currentLocation: locationManager.currentCoordinate
            )
            store.clearPendingCoordinate()
        }
        .onChange(of: locationManager.currentCoordinate) { newCoordinate in
            viewModel.updateCurrentLocation(newCoordinate)
        }
        .onChange(of: store.pendingCoordinate) { pendingCoordinate in
            guard let pendingCoordinate else { return }
            viewModel.applyPendingCoordinate(pendingCoordinate)
            store.clearPendingCoordinate()
        }
    }

    private var locationCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Location", systemImage: "location.fill")
                    .font(.headline)

                Text(viewModel.coordinateSourceText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(viewModel.coordinateText)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.primary)

                Button {
                    locationManager.requestIfNeeded()
                    viewModel.updateCurrentLocation(locationManager.currentCoordinate)
                } label: {
                    Text("Use Current Location")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.blue)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var memoryCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Place")
                    .font(.headline)
                TextField("Place name or quick search", text: $viewModel.placeName)
                    .textInputAutocapitalization(.words)
                    .padding(12)
                    .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text("What happened here?")
                    .font(.headline)
                TextField("A short memory note...", text: $viewModel.note, axis: .vertical)
                    .lineLimit(3...5)
                    .padding(12)
                    .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var returnIntentCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Will you come back?")
                    .font(.headline)

                Picker("Will you come back?", selection: $viewModel.selectedIntent) {
                    ForEach(ReturnIntent.allCases) { intent in
                        Text(intent.title).tag(intent)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var ratingCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Personal rating")
                    .font(.headline)
                StarRatingInputView(rating: $viewModel.personalRating)
                Text("\(viewModel.personalRating)/5")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var vibeCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("One vibe emoji")
                    .font(.headline)
                TextField("✨", text: $viewModel.vibeEmoji)
                    .font(.system(size: 38))
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var saveButton: some View {
        Button {
            let didSave = viewModel.save(in: store)
            guard didSave else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                selectedTab = .map
            }
        } label: {
            Text("Save and forget")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color(red: 0.12, green: 0.42, blue: 0.88)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
        }
        .disabled(!viewModel.canSave)
        .opacity(viewModel.canSave ? 1 : 0.55)
        .padding(.top, 2)
        .frame(maxWidth: .infinity)
    }
}

struct AddPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        AddPlaceView(selectedTab: .constant(.add))
            .environmentObject(PlacesStore.preview)
    }
}
