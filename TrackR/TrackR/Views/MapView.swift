import SwiftUI
import MapKit

struct TrackrMapView: UIViewRepresentable {
    @ObservedObject var locationStore: LocationStore
    @Binding var selectedContact: ContactLocation?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.mapType = .hybridFlyover       // 3D satellite - free
        mapView.isPitchEnabled = true
        mapView.isRotateEnabled = true
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        mapView.showsBuildings = true
        mapView.delegate = context.coordinator

        // Tilted 3D camera
        let camera = MKMapCamera()
        camera.pitch = 55
        camera.altitude = 8000
        mapView.camera = camera

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Remove old contact annotations (keep user location)
        let existing = mapView.annotations.filter { $0 is ContactAnnotation }
        mapView.removeAnnotations(existing)

        // Add updated contacts
        for contact in locationStore.contacts {
            let annotation = ContactAnnotation(contact: contact)
            mapView.addAnnotation(annotation)
        }

        // If a contact is selected, fly camera to them
        if let contact = selectedContact {
            let coord = CLLocationCoordinate2D(
                latitude: contact.latitude,
                longitude: contact.longitude
            )
            let camera = MKMapCamera(
                lookingAtCenter: coord,
                fromDistance: 3000,
                pitch: 60,
                heading: 0
            )
            mapView.setCamera(camera, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TrackrMapView

        init(parent: TrackrMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let contactAnnotation = annotation as? ContactAnnotation else {
                return nil
            }

            let id = "contact-pin"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)

            let contact = contactAnnotation.contact
            view.annotation = annotation
            view.glyphText = contact.initials
            view.titleVisibility = .visible
            view.subtitleVisibility = .visible
            view.animatesWhenAdded = true
            view.canShowCallout = true

            // Color by altitude
            switch contact.altitudeMeters {
            case ..<20:
                view.markerTintColor = UIColor.systemGreen   // ground level
            case 20..<200:
                view.markerTintColor = UIColor.systemBlue    // slight elevation
            case 200..<1000:
                view.markerTintColor = UIColor.systemOrange  // elevated
            default:
                view.markerTintColor = UIColor.systemRed     // very high
            }

            // Lift pin upward on screen proportional to altitude
            // This visually separates elevated contacts from ground level ones
            let lift = min(CGFloat(contact.altitudeMeters) / 15.0, 80.0)
            view.centerOffset = CGPoint(x: 0, y: -lift)

            // Vertical stem line to show height
            if contact.altitudeMeters > 30 {
                view.displayPriority = .required
            }

            return view
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let contactAnnotation = view.annotation as? ContactAnnotation else { return }
            parent.selectedContact = contactAnnotation.contact
        }
    }
}
