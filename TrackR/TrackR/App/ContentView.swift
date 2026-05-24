import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locationStore: LocationStore
    @EnvironmentObject var authService: AuthService
    @State private var selectedContact: ContactLocation? = nil
    @State private var showShare = false
    @State private var showDetail = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Full screen map
            TrackrMapView(
                locationStore: locationStore,
                selectedContact: $selectedContact
            )
            .ignoresSafeArea()

            // Bottom sheet
            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color(.systemGray4))
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                // Header row
                HStack {
                    Text("Sharing with you")
                        .font(.headline)
                    Spacer()
                    Button {
                        showShare = true
                    } label: {
                        Label("Invite", systemImage: "person.badge.plus")
                            .font(.subheadline)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .controlSize(.small)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                if locationStore.contacts.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                        Text("No one is sharing with you yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Tap Invite to share your link")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(locationStore.contacts) { contact in
                                ContactCard(contact: contact)
                                    .onTapGesture {
                                        selectedContact = contact
                                        showDetail = true
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }

                Spacer().frame(height: 8)
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 0)
            .shadow(color: .black.opacity(0.12), radius: 20, y: -4)
        }
        .sheet(isPresented: $showShare) {
            ShareView()
                .environmentObject(authService)
        }
        .sheet(item: $selectedContact) { contact in
            ContactDetailView(contact: contact)
        }
    }
}
