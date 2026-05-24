import SwiftUI
import MapKit

struct ContactDetailView: View {
    let contact: ContactLocation
    @Environment(\.dismiss) private var dismiss

    var altitudeColor: Color {
        switch contact.altitudeMeters {
        case ..<20:    return .green
        case 20..<200: return .blue
        case 200..<1000: return .orange
        default:       return .red
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // Mini map snapshot
                    Map(position: .constant(
                        .region(MKCoordinateRegion(
                            center: CLLocationCoordinate2D(
                                latitude: contact.latitude,
                                longitude: contact.longitude
                            ),
                            latitudinalMeters: 2000,
                            longitudinalMeters: 2000
                        ))
                    )) {
                        Annotation(contact.displayName, coordinate: CLLocationCoordinate2D(
                            latitude: contact.latitude,
                            longitude: contact.longitude
                        )) {
                            ZStack {
                                Circle().fill(altitudeColor).frame(width: 28, height: 28)
                                Text(contact.initials)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .mapStyle(.hybrid(elevation: .realistic))
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(icon: "arrow.up.circle.fill", label: "Altitude",
                                 value: String(format: "%.0f m", contact.altitudeMeters),
                                 color: altitudeColor)
                        StatCard(icon: "speedometer", label: "Speed",
                                 value: String(format: "%.0f km/h", contact.speedKmh),
                                 color: .blue)
                        StatCard(icon: "location.fill", label: "Coordinates",
                                 value: String(format: "%.4f, %.4f", contact.latitude, contact.longitude),
                                 color: .purple)
                        StatCard(icon: "clock.fill", label: "Last update",
                                 value: contact.lastSeenLabel,
                                 color: .secondary)
                    }
                    .padding(.horizontal)

                    // Status banner
                    HStack {
                        Image(systemName: contact.altitudeMeters > 50 ? "mountain.2.fill" : "figure.walk")
                            .foregroundStyle(altitudeColor)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(contact.altitudeMeters > 50 ? "Elevated position" : "Near ground level")
                                .font(.subheadline.weight(.semibold))
                            Text(contact.altitudeMeters > 50
                                 ? "This person is \(Int(contact.altitudeMeters))m above sea level"
                                 : "This person is at approximately ground level")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(altitudeColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                .padding(.top, 8)
            }
            .navigationTitle(contact.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.system(size: 16))
                Spacer()
            }
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color(.systemGray5), lineWidth: 0.5)
        )
    }
}
