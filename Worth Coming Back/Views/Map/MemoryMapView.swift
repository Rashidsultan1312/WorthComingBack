import MapKit
import SwiftUI

private final class MemoryAnnotation: NSObject, MKAnnotation {
    let place: Place

    var coordinate: CLLocationCoordinate2D {
        place.coordinate.clCoordinate
    }

    var title: String? {
        place.name
    }

    var subtitle: String? {
        place.note
    }

    init(place: Place) {
        self.place = place
    }
}

struct MemoryMapView: UIViewRepresentable {
    let places: [Place]
    @Binding var selectedPlace: Place?
    let onQuickAdd: (PlaceCoordinate) -> Void
    let onPlaceTap: (Place) -> Void

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.setRegion(Self.defaultRegion, animated: false)

        let longPressGesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleLongPress(_:))
        )
        longPressGesture.minimumPressDuration = 0.55

        let doubleTapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTripleTap(_:))
        )
        doubleTapGesture.numberOfTapsRequired = 3

        mapView.addGestureRecognizer(doubleTapGesture)
        mapView.addGestureRecognizer(longPressGesture)
        longPressGesture.require(toFail: doubleTapGesture)
        context.coordinator.disableSystemDoubleTapZoomIfNeeded(on: mapView)

        context.coordinator.mapView = mapView
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.syncAnnotations(with: places)

        if let selectedPlace {
            context.coordinator.selectPlace(with: selectedPlace.id)
        } else {
            context.coordinator.clearSelection()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    static var defaultRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 55.03, longitude: 82.92),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MemoryMapView
        weak var mapView: MKMapView?
        private var hasAdjustedInitialRegion = false
        private var annotationsByID: [UUID: MemoryAnnotation] = [:]

        init(parent: MemoryMapView) {
            self.parent = parent
        }

        func syncAnnotations(with places: [Place]) {
            guard let mapView else { return }
            let incoming = Dictionary(uniqueKeysWithValues: places.map { ($0.id, $0) })
            let existingIDs = Set(annotationsByID.keys)
            let incomingIDs = Set(incoming.keys)

            let idsToRemove = existingIDs.subtracting(incomingIDs)
            if !idsToRemove.isEmpty {
                let removable = idsToRemove.compactMap { annotationsByID[$0] }
                mapView.removeAnnotations(removable)
                idsToRemove.forEach { annotationsByID.removeValue(forKey: $0) }
            }

            var annotationsToAdd: [MemoryAnnotation] = []
            for (id, place) in incoming {
                if let existingAnnotation = annotationsByID[id] {
                    guard existingAnnotation.place != place else { continue }
                    mapView.removeAnnotation(existingAnnotation)
                    let newAnnotation = MemoryAnnotation(place: place)
                    annotationsByID[id] = newAnnotation
                    annotationsToAdd.append(newAnnotation)
                } else {
                    let annotation = MemoryAnnotation(place: place)
                    annotationsByID[id] = annotation
                    annotationsToAdd.append(annotation)
                }
            }

            if !annotationsToAdd.isEmpty {
                mapView.addAnnotations(annotationsToAdd)
            }

            if !hasAdjustedInitialRegion, !annotationsByID.isEmpty {
                hasAdjustedInitialRegion = true
                let allAnnotations = Array(annotationsByID.values)
                if allAnnotations.count <= 120 {
                    mapView.showAnnotations(allAnnotations, animated: true)
                }
            }
        }

        func selectPlace(with id: UUID) {
            guard let mapView else { return }
            if let selected = mapView.selectedAnnotations.first as? MemoryAnnotation, selected.place.id == id {
                return
            }
            guard let annotation = annotationsByID[id] else { return }

            mapView.selectAnnotation(annotation, animated: true)
        }

        func clearSelection() {
            guard let mapView else { return }
            guard let selected = mapView.selectedAnnotations.first else { return }
            mapView.deselectAnnotation(selected, animated: true)
        }

        @objc
        func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began, let mapView else { return }
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            parent.onQuickAdd(PlaceCoordinate(coordinate))
        }

        func disableSystemDoubleTapZoomIfNeeded(on mapView: MKMapView) {
            mapView.gestureRecognizers?.forEach { recognizer in
                guard let tap = recognizer as? UITapGestureRecognizer else { return }
                if tap.numberOfTapsRequired == 2 {
                    tap.isEnabled = false
                }
            }
        }

        @objc
        func handleTripleTap(_ gesture: UITapGestureRecognizer) {
            guard gesture.state == .ended, let mapView else { return }
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            parent.onQuickAdd(PlaceCoordinate(coordinate))
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let memoryAnnotation = annotation as? MemoryAnnotation else {
                return nil
            }

            let identifier = "MemoryMarker"
            let markerView = mapView.dequeueReusableAnnotationView(
                withIdentifier: identifier
            ) as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)

            markerView.annotation = memoryAnnotation
            markerView.canShowCallout = false
            markerView.markerTintColor = memoryAnnotation.place.returnIntent.uiColor
            markerView.glyphText = memoryAnnotation.place.vibeEmoji
            markerView.clusteringIdentifier = "memory"
            markerView.displayPriority = .required
            return markerView
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? MemoryAnnotation else { return }
            parent.selectedPlace = annotation.place
            parent.onPlaceTap(annotation.place)
        }

        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            guard let annotation = view.annotation as? MemoryAnnotation else { return }
            if parent.selectedPlace?.id == annotation.place.id {
                parent.selectedPlace = nil
            }
        }
    }
}
