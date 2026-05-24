# TrackR — 3D GPS Tracker for iPhone

See your contacts on a 3D satellite globe with real altitude, speed, and position. Free stack only.

---

## Setup (one time)

### 1. Supabase (free backend)

1. Go to https://supabase.com → New project
2. Go to **SQL Editor** → **New query**
3. Paste the contents of `supabase_setup.sql` → **Run**
4. Go to **Settings** → **API**
5. Copy your **Project URL** and **anon public** key

### 2. Add your Supabase keys

Open `TrackR/Services/SupabaseService.swift` and replace:

```swift
private let SUPABASE_URL = "https://YOUR_PROJECT.supabase.co"
private let SUPABASE_ANON_KEY = "YOUR_ANON_KEY_HERE"
```

### 3. Open in Xcode

1. Open `TrackR.xcodeproj` in Xcode 15+
2. Xcode will automatically resolve the Supabase Swift package (needs internet)
3. Select your iPhone as the run target
4. Hit **Run** (Cmd+R)

> You need a free Apple Developer account to run on a real device.  
> Go to Xcode → Preferences → Accounts → add your Apple ID.

---

## How it works

- **Map**: Apple MapKit `hybridFlyover` — 3D satellite imagery, completely free
- **GPS**: CoreLocation — reads latitude, longitude, altitude (meters above sea level), and speed
- **Sync**: Supabase Realtime — pushes your location every few meters, contacts update live
- **3D pins**: Pins are lifted upward on screen proportional to real altitude, so someone on a mountain visually floats above someone at ground level

## Altitude colors

| Color | Altitude |
|-------|----------|
| Green | 0–20m (ground) |
| Blue | 20–200m (slight elevation) |
| Orange | 200–1000m (mountain/hill) |
| Red | 1000m+ (very high) |

---

## File structure

```
TrackR/
├── App/
│   ├── TrackRApp.swift          — entry point
│   └── ContentView.swift        — main layout
├── Views/
│   ├── MapView.swift            — MapKit 3D satellite map
│   ├── ContactCard.swift        — horizontal scroll cards
│   ├── ContactDetailView.swift  — full stats sheet
│   ├── AuthView.swift           — sign in / sign up
│   └── ShareView.swift          — invite link
├── Models/
│   ├── ContactLocation.swift    — data model
│   └── ContactAnnotation.swift  — map pin wrapper
└── Services/
    ├── LocationStore.swift      — CoreLocation + realtime sync
    ├── SupabaseService.swift    — all DB calls ← put your keys here
    └── AuthService.swift        — sign in / sign up
```

---

## Bug fixes / updates

Drop replacement `.swift` files into the matching folder and rebuild.
