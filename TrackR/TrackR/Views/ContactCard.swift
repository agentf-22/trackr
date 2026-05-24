import SwiftUI

struct ContactCard: View {
    let contact: ContactLocation

    var altitudeColor: Color {
        switch contact.altitudeMeters {
        case ..<20:   return .green
        case 20..<200: return .blue
        case 200..<1000: return .orange
        default:      return .red
        }
    }

    var altitudeLabel: String {
        switch contact.altitudeMeters {
        case ..<20:   return "Ground"
        case 20..<200: return "Low"
        case 200..<1000: return "Elevated"
        default:      return "High alt."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                // Avatar circle
                ZStack {
                    Circle()
                        .fill(altitudeColor.opacity(0.15))
                    Text(contact.initials)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(altitudeColor)
                }
                .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 1) {
                    Text(contact.displayName)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    Text(contact.lastSeenLabel)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            // Stats row
            HStack(spacing: 10) {
                Label(String(format: "%.0fm", contact.altitudeMeters), systemImage: "arrow.up")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(altitudeColor)

                Label(String(format: "%.0f km/h", contact.speedKmh), systemImage: "speedometer")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            // Altitude badge
            Text(altitudeLabel)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(altitudeColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(altitudeColor.opacity(0.12), in: Capsule())
        }
        .padding(12)
        .frame(width: 170)
        .background(.background, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(altitudeColor.opacity(0.25), lineWidth: 0.5)
        )
    }
}
