import Foundation
import Supabase

// ─────────────────────────────────────────────
// SETUP: Replace these two values with yours
//   1. Go to supabase.com → your project → Settings → API
//   2. Copy "Project URL" and "anon public" key
// ─────────────────────────────────────────────
private let SUPABASE_URL = "https://jljciwmzcgcmsnyepdcp.supabase.co"
private let SUPABASE_ANON_KEY = "sb_publishable_KcD9bvCdISQL0frYplCRQw_jlcCwP0D"

final class SupabaseService {
    static let shared = SupabaseService()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: SUPABASE_URL)!,
            supabaseKey: SUPABASE_ANON_KEY
        )
    }

    var currentUserId: String? {
        client.auth.currentUser?.id.uuidString
    }

    // Push / update my location row
    func upsertMyLocation(lat: Double, lng: Double, altitudeM: Double, speedKmh: Double) async throws {
        guard let uid = currentUserId else { return }
        let profile = try await client.from("profiles")
            .select("display_name")
            .eq("id", value: uid)
            .single()
            .execute()

        // Upsert into locations table
        try await client.from("locations")
            .upsert([
                "id": uid,
                "user_id": uid,
                "lat": String(lat),
                "lng": String(lng),
                "altitude_m": String(altitudeM),
                "speed_kmh": String(speedKmh),
                "updated_at": ISO8601DateFormatter().string(from: Date())
            ])
            .execute()
    }

    // Fetch all contacts sharing with me (excluding myself)
    func fetchContactLocations(excludingUserId: String) async throws -> [ContactLocation] {
        let response = try await client.from("location_shares")
            .select("""
                locations!inner(
                    id, user_id, lat, lng, altitude_m, speed_kmh, updated_at,
                    profiles!inner(display_name)
                )
            """)
            .eq("shared_with_user_id", value: excludingUserId)
            .execute()

        // Decode from the nested join result
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        // Flatten the nested response into ContactLocation objects
        // (Supabase returns nested join; parse manually for reliability)
        guard let array = try JSONSerialization.jsonObject(with: response.data) as? [[String: Any]] else {
            return []
        }

        return array.compactMap { row -> ContactLocation? in
            guard
                let loc = row["locations"] as? [String: Any],
                let id = loc["id"] as? String,
                let userId = loc["user_id"] as? String,
                let lat = Double(loc["lat"] as? String ?? ""),
                let lng = Double(loc["lng"] as? String ?? ""),
                let alt = Double(loc["altitude_m"] as? String ?? "0"),
                let spd = Double(loc["speed_kmh"] as? String ?? "0"),
                let updatedStr = loc["updated_at"] as? String,
                let updated = ISO8601DateFormatter().date(from: updatedStr),
                let profile = loc["profiles"] as? [String: Any],
                let name = profile["display_name"] as? String
            else { return nil }

            return ContactLocation(
                id: id,
                userId: userId,
                displayName: name,
                latitude: lat,
                longitude: lng,
                altitudeMeters: alt,
                speedKmh: spd,
                updatedAt: updated
            )
        }
    }

    // Stream realtime location table changes
    func locationChanges() -> AsyncStream<Void> {
        AsyncStream { continuation in
            Task {
                let channel = client.realtimeV2.channel("public:locations")
                await channel.subscribe()
                for await _ in channel.postgresChanges(AnyAction.self, table: "locations") {
                    continuation.yield()
                }
            }
        }
    }
}
