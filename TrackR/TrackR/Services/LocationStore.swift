import Foundation
import CoreLocation
import Combine

@MainActor
class LocationStore: NSObject, ObservableObject {
    @Published var contacts: [ContactLocation] = []
    @Published var myLocation: CLLocation?
    @Published var locationError: String?

    private let locationManager = CLLocationManager()
    private var updateTimer: Timer?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 5   // update every 5m movement
    }

    func start() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        subscribeToContacts()
    }

    // Push my location to Supabase every time it updates
    private func pushLocation(_ location: CLLocation) {
        Task {
            do {
                try await SupabaseService.shared.upsertMyLocation(
                    lat: location.coordinate.latitude,
                    lng: location.coordinate.longitude,
                    altitudeM: location.altitude,
                    speedKmh: max(0, location.speed) * 3.6
                )
            } catch {
                print("Location push error: \(error)")
            }
        }
    }

    // Subscribe to real-time updates from contacts
    private func subscribeToContacts() {
        Task {
            // Initial fetch
            await fetchContacts()

            // Then listen for realtime changes
            for await _ in SupabaseService.shared.locationChanges() {
                await fetchContacts()
            }
        }
    }

    private func fetchContacts() async {
        do {
            let userId = SupabaseService.shared.currentUserId ?? ""
            contacts = try await SupabaseService.shared.fetchContactLocations(excludingUserId: userId)
        } catch {
            print("Fetch contacts error: \(error)")
        }
    }
}

extension LocationStore: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.myLocation = location
            self.pushLocation(location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.locationError = error.localizedDescription
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                manager.startUpdatingLocation()
            case .denied, .restricted:
                self.locationError = "Location access denied. Please enable in Settings."
            default:
                break
            }
        }
    }
}
