import PhotosUI
import SwiftUI
import UIKit

struct PlaceDetailView: View {
    @EnvironmentObject private var store: PlacesStore
    @Environment(\.dismiss) private var dismiss

    let placeID: UUID

    @State private var note = ""
    @State private var rating = 4
    @State private var returnIntent: ReturnIntent = .yes
    @State private var photoData: Data?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var hasLoaded = false

    private var place: Place? {
        store.place(with: placeID)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                if let place {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            photoCard(place: place)
                            notesCard
                            ratingCard
                            intentCard
                            metaCard(place: place)
                            saveButton
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .padding(.bottom, 32)
                    }
                } else {
                    GlassCard {
                        Text("Place not found.")
                            .font(.headline)
                    }
                    .padding()
                }
            }
            .navigationTitle("Place Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadStateIfNeeded()
        }
        .onChange(of: selectedPhoto) { newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    photoData = compressedImageData(from: data)
                }
            }
        }
    }

    private func photoCard(place: Place) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("\(place.vibeEmoji) \(place.name)")
                    .font(.title3.weight(.bold))

                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.65))
                        .frame(height: 220)

                    if let imageData = photoData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 36))
                                .foregroundStyle(.secondary)
                            Text("No photo yet")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Text(photoData == nil ? "Add Photo" : "Change Photo")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.blue)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var notesCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Your comment")
                    .font(.headline)
                TextEditor(text: $note)
                    .scrollContentBackground(.hidden)
                    .frame(height: 120)
                    .padding(8)
                    .background(Color.white.opacity(0.65), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var ratingCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Personal rating")
                    .font(.headline)
                StarRatingInputView(rating: $rating)
                Text("\(rating)/5")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var intentCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Come back?")
                    .font(.headline)
                Picker("Come back", selection: $returnIntent) {
                    ForEach(ReturnIntent.allCases) { intent in
                        Text(intent.title).tag(intent)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func metaCard(place: Place) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Meta")
                    .font(.headline)
                Text("Saved: \(place.createdAt.mediumDate)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Location: \(place.coordinate.shortLabel)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var saveButton: some View {
        Button {
            store.updatePlace(
                id: placeID,
                note: note,
                returnIntent: returnIntent,
                personalRating: rating,
                photoData: photoData
            )
            dismiss()
        } label: {
            Text("Save Changes")
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
        .frame(maxWidth: .infinity)
    }

    private func loadStateIfNeeded() {
        guard !hasLoaded, let place else { return }
        hasLoaded = true
        note = place.note
        rating = place.personalRating ?? 4
        returnIntent = place.returnIntent
        photoData = place.photoData
    }

    private func compressedImageData(from data: Data) -> Data {
        guard let image = UIImage(data: data) else { return data }
        return image.jpegData(compressionQuality: 0.78) ?? data
    }
}

struct PlaceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let store = PlacesStore.preview
        return PlaceDetailView(placeID: store.places.first?.id ?? UUID())
            .environmentObject(store)
    }
}
