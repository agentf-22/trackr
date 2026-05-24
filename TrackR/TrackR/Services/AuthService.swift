import Foundation
import Supabase

@MainActor
class AuthService: ObservableObject {
    @Published var isSignedIn = false
    @Published var currentUserId: String?

    private var client: SupabaseClient { SupabaseService.shared.client }

    init() {
        Task {
            // Check existing session on launch
            if let session = try? await client.auth.session {
                isSignedIn = true
                currentUserId = session.user.id.uuidString
            }

            // Listen for auth state changes
            for await (event, session) in client.auth.authStateChanges {
                switch event {
                case .signedIn:
                    isSignedIn = true
                    currentUserId = session?.user.id.uuidString
                    if let uid = currentUserId {
                        try? await ensureProfile(userId: uid, email: session?.user.email ?? "")
                    }
                case .signedOut:
                    isSignedIn = false
                    currentUserId = nil
                default:
                    break
                }
            }
        }
    }

    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        try await client.auth.signUp(email: email, password: password)
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    // Create profile row on first sign up
    private func ensureProfile(userId: String, email: String) async throws {
        let existing = try? await client.from("profiles")
            .select("id")
            .eq("id", value: userId)
            .single()
            .execute()

        if existing == nil {
            let defaultName = email.components(separatedBy: "@").first ?? "User"
            try await client.from("profiles")
                .insert(["id": userId, "display_name": defaultName])
                .execute()
        }
    }
}
