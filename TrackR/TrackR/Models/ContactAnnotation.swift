import MapKit

class ContactAnnotation: NSObject, MKAnnotation {
    let contact: ContactLocation

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: contact.latitude, longitude: contact.longitude)
    }

    var title: String? { contact.displayName }

    var subtitle: String? {
        String(format: "↑%.0fm  %.0f km/h", contact.altitudeMeters, contact.speedKmh)
    }

    init(contact: ContactLocation) {
        self.contact = contact
        super.init()
    }
}
