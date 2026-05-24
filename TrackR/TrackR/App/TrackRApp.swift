import SwiftUI

@main
struct TrackRApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var locationStore = LocationStore()

    var body: some Scene {
        WindowGroup {
            if authService.isSignedIn {
                ContentView()
                    .environmentObject(authService)
                    .environmentObject(locationStore)
                    .onAppear {
                        locationStore.start()
                    }
            } else {
                AuthView()
                    .environmentObject(authService)
            }
        }
    }
}
