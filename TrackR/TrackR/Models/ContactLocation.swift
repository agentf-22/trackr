import Foundation

struct ContactLocation: Identifiable, Codable {
    let id: String
    let userId: String
    var displayName: String
    var latitude: Double
    var longitude: Double
    var altitudeMeters: Double
    var speedKmh: Double
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case displayName = "display_name"
        case latitude = "lat"
        case longitude = "lng"
        case altitudeMeters = "altitude_m"
        case speedKmh = "speed_kmh"
        case updatedAt = "updated_at"
    }

    var initials: String {
        let parts = displayName.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(displayName.prefix(2)).uppercased()
    }

    var lastSeenLabel: String {
        let diff = Date().timeIntervalSince(updatedAt)
        switch diff {
        case ..<5:      return "Just now"
        case ..<60:     return "\(Int(diff))s ago"
        case ..<3600:   return "\(Int(diff/60))m ago"
        default:        return "\(Int(diff/3600))h ago"
        }
    }
}
