# Bajada

*A padel score tracker for Apple Watch and iPhone.*

Keep padel score from your Apple Watch: who's serving and from which side, golden point / Star Point, tie-breaks and super tie-breaks. An iPhone companion handles history, stats and sharing.

**Status:** Phase 0 (plumbing: the app installs and a HealthKit test runs; no scoring yet). Start with the plan: **[PLAN.md](PLAN.md)**.

![Apple Watch mockups](docs/mockups/watch-scoring.svg)

## Install on your iPhone and Ultra

No paid developer account needed: you install from Xcode on a Mac with a free Apple Account. The signature lasts **7 days**, so you re-run the deploy once a week (your match history survives). Details and trade-offs are in [PLAN.md §6](PLAN.md).

1. **Install Xcode 26 or later** (Mac App Store) and XcodeGen: `brew install xcodegen`.
2. **Add your Apple Account** in *Xcode → Settings → Accounts*. Xcode creates your free *Personal Team*.
3. **Generate the project:** `make setup TEAM_ID=XXXXXXXXXX`.
   - Find your Team ID in *Xcode → Settings → Accounts →* select your account, and read the 10-character ID next to your Personal Team (or at developer.apple.com/account, under Membership details).
   - This writes the gitignored `Local.xcconfig` and creates `Bajada.xcodeproj`.
4. **Turn on Developer Mode** on the iPhone (*Settings → Privacy & Security → Developer Mode*, then restart) and on the Ultra (same path on the watch; it appears once Xcode has seen the watch). Connect the iPhone by cable the first time and tap *Trust*.
5. **First install from Xcode:** open `Bajada.xcodeproj` and press Run on `Bajada` with the iPhone selected, then on `BajadaWatch` with the Ultra selected. Doing the first run in Xcode lets it register both devices with your free team and answer the one-time keychain prompt for signing.
   After that, `make deploy` rebuilds and installs both apps from the terminal with `xcrun devicectl`. It has not been verified on hardware yet; if it fails, pressing Run in Xcode always works.
6. **First launch only:** on the iPhone, trust your profile in *Settings → General → VPN & Device Management*.
7. **Every week:** run `make deploy` again, ideally the evening before you play.

Other commands: `make test` runs the PadelKit unit tests (`swift test`); `IPHONE_ID=… WATCH_ID=…` override device auto-detection (IDs come from `xcrun devicectl list devices`).

## Phase 0 checklist for the owner

Phase 0 answers one question: **can a free Personal Team sign HealthKit?**

- [ ] `make setup TEAM_ID=…` then `make deploy` succeeds, and the app opens on the iPhone and on the Ultra.
- [ ] iPhone screen shows "Bajada", the version, and the watch status (paired / app installed / reachable). Tap **Ping watch** and note the reply (open the watch app first so it is reachable).
- [ ] On the watch, open **Health check** and tap **Run check**. It requests Health permission (allow it), runs a 4-second tennis workout, then ends it. Each step shows OK or the exact error in red.
- [ ] Report back: which steps passed, and the red error text if any (a screenshot of the watch is perfect).
- [ ] **If signing fails over HealthKit** (Xcode says the profile doesn't support the HealthKit capability, or the app won't install), re-run without it: `make setup TEAM_ID=… NO_HEALTHKIT=1`, then `make deploy`. This removes the entitlement and the workout background mode and compiles the HealthKit code out. Scoring will still work; see [PLAN.md §6](PLAN.md) for what is dropped.
- [ ] Note that the free-team limits are 3 apps per device and 10 App IDs per week; the project is just two targets (iPhone app and its watch app) to stay within that.

## Repository layout (Phase 0)

| Path | What |
|---|---|
| `project.yml` | XcodeGen spec that generates `Bajada.xcodeproj` (never committed) |
| `Config/Base.xcconfig`, `Local.xcconfig` | Shared settings; your gitignored team ID and HealthKit switch |
| `Packages/PadelKit/` | Swift package for the rules engine (placeholder in Phase 0) |
| `PhoneApp/`, `WatchApp/` | The iPhone app and the watch app (SwiftUI) |
| `Makefile` | `setup`, `deploy`, `test` |
| `.github/workflows/ci.yml` | PadelKit tests on Linux, unsigned iOS + watch build on macOS (with and without HealthKit) |
