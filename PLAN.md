# Padel Score Tracker: Plan

An iPhone + Apple Watch app, designed for the Apple Watch Ultra first. It keeps the padel score, shows who is serving and from which side, logs the match as a workout, and makes results easy to share.

> **Status:** planning. Nothing is built yet; this is the proposal to agree on first.
> Research done in September 2026, when watchOS 27 / iOS 27 were current.

![Apple Watch mockups: scoring, Star Point, summary](docs/mockups/watch-scoring.svg)

---

## TL;DR

- **Build a native SwiftUI app.** A watch app scores on court, and an iPhone companion handles setup, history, stats and sharing. Watch apps have to be native Swift: web apps, React Native and Flutter cannot run on the watch.
- **Put all padel logic in one small Swift package (`PadelKit`).** It is a pure, heavily tested engine that replays a log of points. That one design choice gives unlimited undo, crash-proof matches, sync and stats almost for free.
- **Install through TestFlight, built in the cloud by GitHub Actions.** No Mac is needed. It does need the Apple Developer Program ($99/yr). Push code, the build appears in TestFlight, you install it on the iPhone, and the watch app comes with it.
- **Sharing:**
  - a TestFlight public link and QR code (up to 10,000 people),
  - result share cards for WhatsApp and Instagram,
  - later, a free App Store listing.
- **Where it beats existing apps:**
  - scoring you can trust (the clearest complaint in their reviews is a lost score),
  - no paywall,
  - two Ultra features none of the apps checked advertise: **Action Button** to start a match or undo, and **Double Tap** to score.

---

## 1. What's already out there

There are a dozen or more padel scorers on the App Store. Almost all are small indie apps with a handful of ratings each, and they have converged on the same core. The most complete ones:

| App | Price | Stand-out features |
|---|---|---|
| [Padel Score Counter][pcounter] | $3.99 once | Serve order per set and tie-break (re-orderable each set), golden and star point, short sets, workout logging, iPhone history. Phone sync only works on the same network. |
| [Padel Watch][pwatch] | Free + $3–4/mo | One-tap scoring, serve order you can fix mid-match, advantage/golden/star, stats (break points, streaks), point-by-point replay, post/story share formats. |
| [PadelTick][ptick] | Free + $4/mo or $35/yr | FIP serve order, star point, restores a match if the app closes, live scoreboard on iPhone/iPad, Americano across courts. Best rated: 4.9★ from 18 ratings. |
| [Padel Pointer][ppointer] | Free + Pro $5–50 | Colour-coded tap zones, server/side/player rotation, serve reminders, complications, classic/golden/silver/star, FAST4, Americano 16–32 pts, hold/break analytics, 9:16 story cards. |
| [PadelTracker Pro][ptracker] | Free + $7, ads | Live Activity and Dynamic Island, Always-On score, GPS court heatmap, heart rate vs. momentum, iCloud sync, share cards. |
| [PadelPro][ppro] | Free + $25–40/yr | "Under a second" scoring, voice announcements, break/set/match-point badges, Americano, changeover timer, no account or ads. |
| [Padel Point][ppoint] | Free (tip jar) | Deuce counter, random server pick, voice call-outs, Americano / Mexicano / King of the Court with leaderboards, spectator scoreboard, CSV export. |

Also checked:
- [Padela][padela]
- [Padelore][padelore]: the iPhone becomes a courtside scoreboard, propped against the net post.
- [Tennis Padel Score Keeper][tpsk]: "TV-broadcast" style voice score.

**What this tells us**

1. **Table stakes.** Every serious app has:
   - a big tap zone per team, and undo;
   - automatic server rotation, with a way to fix it;
   - the serving side;
   - advantage, golden point and star point;
   - tie-breaks and super tie-breaks;
   - a HealthKit workout, iPhone history, and a share card.
2. **Reliability is where they lose people.**
   - The clearest review complaint: *"App closes in the middle of a set and when I re-open it it resets"* (Padel Watch).
   - One app's changelog lists fixes for taps lost when you raise your wrist, *"score loss"* and *"duplicate points"* (PadelTracker Pro).
   - Keeping the score intact is feature #1.
3. **Ultra gap.** None of the listings checked advertise the Ultra's Action Button or Double Tap.
4. **Paywalls everywhere.** Most gate stats behind a weekly, monthly or yearly subscription. This app is personal: no paywall, no account, no ads, and the data stays on your devices.
5. **Extras worth borrowing:**
   - voice score calls,
   - a courtside scoreboard on the phone,
   - a Live Activity,
   - Americano and Mexicano,
   - hold/break stats,
   - CSV export.

---

## 2. What we'll build

### MVP: "I can play a real match with it"

**Watch**
- **Starting a match:** *Quick start* reuses your last settings. A new match takes three taps or fewer: format, then who serves first, then go.
- **Formats:**
  - best of 1, 3 or 5 sets;
  - 6-game sets with a tie-break at 6–6;
  - deuce rule: **Advantage / Golden point / Star Point / Silver point**;
  - deciding set played in full, or as a **super tie-break to 10**.
- **Tap to score.** The top half scores for your team and the bottom half for the opponents. Every tap is confirmed with a haptic, and undo is unlimited.
- **Serving:**
  - shows who serves and from which side (right/left);
  - at golden and star points, shows that the receivers choose the side;
  - asks about serve order at the start of each set (defaulting to the previous order);
  - lets you correct the server at any time.
- **Alerts:** change ends, tie-break, set point, match point, break point.
- **Crash-proof.** Every point is saved the moment it happens. An interrupted match resumes exactly where it stopped.
- **Workout.** Runs a HealthKit workout session, so the app stays on screen when you raise your wrist. Heart rate and calories go to Fitness.
- **Summary** at the end, sent to the iPhone automatically.

**iPhone**
- Match history and match detail: sets and duration.
- Player names, synced to the watch.
- A result share card image.

### v0.2: companion and sharing
- **Courtside scoreboard.** Big landscape digits that mirror the watch live. It can also keep score on its own, for friends without a watch.
- **Live Activity** on the lock screen and in the Dynamic Island.
- **Stats:**
  - holds and breaks;
  - break points saved and converted;
  - deuce, golden and star points won;
  - streaks;
  - a momentum chart (Swift Charts).
- Share cards in square and 9:16 story formats, plus CSV/JSON export.
- An external TestFlight group, plus an **Invite friends** QR code in the app.

### v0.3: Ultra extras and polish
- **Action Button.** The first press starts a match. Presses during a match run a configurable action (default **Undo**).
- **Double Tap** (Ultra 2 and later) scores a point for your team. Opt-in.
- **Voice calls** through the Ultra's speaker: "Thirty–fifteen", "Star point", "Change ends".
- A complication / Smart Stack widget, and a dimmed Always-On layout.
- A changeover timer: 90 s at a change of ends, 120 s between sets.

### Later / maybe
- Americano and Mexicano sessions: points races, rotating partners, a leaderboard.
- Optional point tagging: winner, error, ace, double fault.
- iCloud backup.
- Spanish localisation.
- App Store release.
- A spectator web link.

### Not doing
- accounts or a backend
- subscriptions or ads
- Android
- GPS heatmaps
- video or AI line-calling

---

## 3. Padel rules the engine must get right

Sources: the [FIP Rules of Padel][fiprules] (2026 edition) and the FIP's [Star Point announcement][fipstar].

**Games**
- Points go 0 → 15 → 30 → 40 → game.
- At 40–40, the match's deuce rule applies. The rule is chosen once per match and applies to every deuce.
  - **Advantage:** win by two, however long it takes.
  - **Golden point:** the next point wins the game. The receiving pair chooses which side receives.
  - **Star Point** (FIP):
    - In force since 1 Jan 2026 in Premier Padel, the CUPRA FIP Tour, FIP Promises and FIP Beyond.
    - The first two deuces are played with advantage.
    - At the **third** deuce, a single deciding point is played.
    - The receiving pair chooses the side, but may not swap positions to do it.
  - **Silver point** (offered by some apps and events): one advantage, then a deciding point at the second deuce.

**Sets and tie-breaks**
- A set goes to the first pair to 6 games with a 2-game lead.
- At 6–6 there is a **tie-break**: points are counted 1, 2, 3…, first to 7 wins with a 2-point lead, and the set is recorded as 7–6.
- **Tie-break serving:**
  - The player due to serve serves **one** point, from the right.
  - After that, the serve changes every **two** points in the normal order; each turn starts from the left.
  - Ends change **every 6 points**.
  - The next set is started by the pair that **did not** serve first in the tie-break.
- A **super (match) tie-break** can replace the deciding set. It goes to 10 with a 2-point lead and is served like a normal tie-break.

**Serve and receive order (doubles)**
- The serve rotates A1 → B1 → A2 → B2.
- Each pair picks its first server when it first serves in a set. That order holds for the set, and **can change at the start of every set**.
- The first point of every game is served from the **right**; after that the side alternates every point.
- Receiving positions (right or left) are fixed for the set. In practice, padel players keep their side (drive or revés) all match.

**Changing ends and rest**
- Ends change after games 1, 3, 5 and so on in each set.
- At the end of a set, ends change if the set's game total is odd. If it is even, they change after the first game of the next set.
- In tie-breaks, ends change every 6 points.
- Rest limits, used by the optional timer:
  - 20 s between points,
  - 90 s at a change of ends,
  - 120 s between sets.

**Presets** (every field stays editable)

| Preset | Deuce | Sets | Deciding set |
|---|---|---|---|
| Pro 2026 (FIP / Premier Padel) | Star Point | Best of 3, tie-break at 6–6 | Full set |
| Club | Golden point | Best of 3, tie-break at 6–6 | Super tie-break to 10 |
| Classic | Advantage | Best of 3, tie-break at 6–6 | Full set |
| Americano *(later)* | — | Race to 16 / 24 / 32 points | — |

**What the engine reports after every point:**
- the score text, games and sets;
- **the current server and the side they serve from**;
- which deuce number it is;
- whether it's a deciding point (the receivers pick the side);
- the pressure point (game, set, match or break point);
- whether ends are about to change;
- the winner.

---

## 4. Experience

### Apple Watch: the main event

**Flow:**
1. **Home:** ▶ Quick start · New match · History.
2. **Setup:**
   - pick a preset;
   - player names are optional and synced from the phone;
   - choose who serves first: tap a team, or 🎲 to pick at random.
3. **Scoring.**
4. **Summary.**

**Scoring screen** (see the mockup above)
- Two huge tap zones in team colours: top for your team, bottom for the opponents. The points are the biggest thing on screen, with games and sets above them.
- A 🟡 ball marker shows the serving team, the server's name, and the side they serve from.
- Banners for *Deuce 2*, *★ Star point: receivers pick a side*, *Tie-break*, *Set point* and *Match point*.
- A small **Undo** button is always visible.
- Swipe right for the controls: pause, end match, fix server, settings.
- Swipe left for Now Playing, like Apple's Workout app.
- A full-screen **⇄ Change ends** card, with its own haptic, that closes by itself.

**Details that make it trustworthy**
- **Haptics you can feel without looking:** one for our point, a different one for theirs, *success* for a game, *notification* for a set.
- **No accidental double points:** a second tap on the same zone within about 0.4 s is ignored.
- **Always-On safety:** when the watch is dimmed, a tap only wakes the screen and must **never** score. The dimmed screen shows a low-power, score-only layout.
- **Readable outdoors:** high-contrast colours and huge digits for bright sun.

**Ultra extras (v0.3)**
- **Action Button:**
  - Choose it in *Settings → Action Button → Workout*.
  - The first press starts a match with your quick-start settings.
  - Presses during a match run a configurable action (default **Undo**).
  - How it works: the app implements `StartWorkoutIntent` ([docs][actionbtn], [example][actionbtnex]), which returns `.result(actionButtonIntent:)` to decide what the next press does.
- **Double Tap** (Ultra 2 / 3 / 4, watchOS 11+):
  - `.handGestureShortcut(.primaryAction)` on "point for us".
  - Opt-in, because gripping a racket or catching a ball can trigger it.
- **Voice calls:** spoken with `AVSpeechSynthesizer` through the Ultra's loud speaker. Off by default.

### iPhone: the companion
- **Matches:**
  - history;
  - match detail: score line, set by set, momentum chart, stats, duration and heart rate;
  - **Share**.
- **Scoreboard:** landscape, giant digits, mirrors the watch live; it can also keep score directly.
- **Players:** names and usual side (drive or revés), synced to the watch.
- **Settings:**
  - default preset;
  - your team's colour and position;
  - haptics and voice;
  - what the Action Button and Double Tap do;
  - **Invite friends** (QR code).

---

## 5. Architecture

```
padel-score-tracker-app/
├── project.yml                  # XcodeGen spec → generates the .xcodeproj (never hand-edited)
├── Packages/PadelKit/           # pure Swift, Foundation only: the rules engine
│   ├── Sources/PadelKit/        # MatchConfig, MatchEvent, MatchState, replay, serve logic, stats
│   └── Tests/PadelKitTests/     # table-driven + randomized tests (also run on Linux)
├── WatchApp/                    # watchOS app (SwiftUI)
│   ├── Setup/  Scoring/  Summary/
│   ├── Workout/                 # HKWorkoutSession + HKLiveWorkoutBuilder, crash recovery
│   ├── Intents/                 # StartWorkoutIntent (Action Button) + in-match intents
│   ├── Store/                   # append-only match journal (JSON, atomic writes)
│   └── Sync/                    # WatchConnectivity
├── PhoneApp/                    # iOS app (SwiftUI + SwiftData + Swift Charts)
│   ├── Matches/  Stats/  Players/  Scoreboard/  Share/  Settings/
│   └── Sync/
├── Widgets/                     # watch complication + iPhone Live Activity (v0.2–v0.3)
└── .github/workflows/
    ├── ci.yml                   # every push: engine tests + unsigned iOS/watchOS build
    └── testflight.yml           # manual / tag / monthly: sign in the cloud → TestFlight
```

**Key decisions**

- **Swift 6 + SwiftUI, with a minimum of iOS 18 / watchOS 11.**
  - This still runs on the **original Ultra**: [watchOS 27 dropped it][watchos27], so it stays on watchOS 26.
  - It also covers friends' older devices, and still allows Double Tap.
  - Builds use **Xcode 26 or later**, which App Store Connect has [required for uploads since 28 April 2026][sdkreq].
- **XcodeGen.** The project is described in readable YAML, so it can be edited from anywhere, diffs stay clean, and CI generates the project from scratch.
- **Event sourcing.** A match is just `config + [events]`.
  - Events: a point won by A or B, a serve-order choice, a server correction.
  - `state = replay(config, events)`. A match is about 150–300 points, so replaying is instant.
  - This gives, almost for free:
    - **undo:** drop the last event;
    - **persistence:** append the event and write the file atomically after every point;
    - **sync:** send the events;
    - **stats:** walk through the replay;
    - **tests:** feed in point sequences and check the resulting state.
- **The watch owns the live match; the phone is the archive.**
  - **Watch → phone, finished match:** sent with `WCSession.transferUserInfo`. It is queued, survives restarts, and needs no shared Wi-Fi.
  - **Watch → phone, live score:** sent with `sendMessage` while the phone is reachable. This feeds the scoreboard and the Live Activity.
  - **Phone → watch:** players, presets and settings, sent with `updateApplicationContext`.
  - No server and no account. The watch stores JSON files; the phone uses SwiftData.
- **Workout:** `HKWorkoutSession` + `HKLiveWorkoutBuilder`.
  - HealthKit has [no padel activity type][nopadeltype], so it logs as `.tennis` by default. The type is configurable, and the score goes into the workout's metadata.
  - After a crash, the session comes back through `handleActiveWorkoutRecovery()`.
  - HealthKit sits behind a build flag, so a build without it still keeps score.

```swift
// PadelKit, sketch only
enum DeuceRule   { case advantage, golden, silver, star }
enum DecidingSet { case fullSet, superTiebreak(to: Int) }   // usually 10

struct MatchConfig {
    var bestOf = 3, gamesPerSet = 6, tiebreakAt = 6
    var deuce: DeuceRule = .golden
    var decidingSet: DecidingSet = .superTiebreak(to: 10)
}

enum MatchEvent: Codable {        // the only thing that is stored and synced
    case point(winner: TeamID, at: Date)
    case serveOrder(set: Int, firstServer: PlayerID)
    case fixServer(PlayerID)
}

// MatchState is always derived, never stored: sets, games, points, server,
// serve side (.right/.left), deuce count, deciding point?, game/set/match/break
// point, change-ends pending, winner.
func replay(_ config: MatchConfig, _ events: [MatchEvent]) -> MatchState
```

---

## 6. Getting it onto your iPhone and Ultra

In practice, an app reaches an Apple Watch in one of two ways:
- **Xcode**, building it and installing it directly;
- **Apple's distribution:** TestFlight or the App Store.

(Ad hoc builds also work, but they need the same paid account plus registering every device, so TestFlight is simpler.) Web apps can't run on the watch, and [AltStore / SideStore can't install watch apps][sideload]. That leaves three realistic routes:

| Route | Cost | Mac needed? | Re-install | Share with friends |
|---|---|---|---|---|
| **A. TestFlight, built by GitHub Actions** ✅ | $99/yr | **No** | Never: builds last 90 days and are rebuilt automatically | ✅ public link, up to 10,000 people |
| B. Xcode + free Apple Account | Free | Yes | **Every 7 days** | ❌ each friend would have to build it |
| C. App Store (later; same account as A) | $99/yr | No | Never | ✅ anyone, via search or link |

**Recommendation: Route A.** It is the only route that is both easy to install *and* easy to share, and it doesn't need a Mac.

### Route A, step by step
This is a one-time setup: about an hour of your time, plus Apple's approval wait.

1. **Enroll** in the [Apple Developer Program][enroll] as an *Individual*.
   - In most countries you can do this from the **Apple Developer app on your iPhone**.
   - It costs $99/yr, and your Apple Account needs two-factor authentication.
   - Approval can take a day or two.
2. **Register the app IDs** `com.<you>.padel` and `com.<you>.padel.watchkitapp` under developer.apple.com → Identifiers, and tick HealthKit on both.
3. **Create the app** in App Store Connect → Apps → ＋ New App, using that bundle ID. The name must be unique on the store.
4. **Create an API key** in App Store Connect → Users and Access → Integrations.
   - Give it the **Admin** role, so Xcode can create signing certificates in the cloud.
   - Download the `.p8` file. You can only download it once.
   - Note the Key ID and the Issuer ID.
5. **Add GitHub secrets** `ASC_KEY_ID`, `ASC_ISSUER_ID` and `ASC_KEY_P8`, plus a variable `APPLE_TEAM_ID`.
6. **Run the "TestFlight" workflow.** Roughly 15–30 minutes later (the build plus Apple's processing), it shows up in TestFlight.
7. **On the iPhone:**
   - install **TestFlight**, accept the invite and tap Install;
   - the watch app installs itself. If it doesn't, open the Watch app → Available Apps → Install.

After that, every tagged release lands in TestFlight and updates on your phone and watch. A **monthly scheduled build** keeps you clear of the 90-day expiry.

### Route B: free, but only if you own a Mac
- **Setup:** run `brew install xcodegen && xcodegen`, open the project, pick your *Personal Team*, and run it on the iPhone. Developer Mode must be on for both the iPhone and the watch.
- **Limits:** the signature **expires after 7 days**, and you can have at most 3 such apps per device. So you re-run from Xcode every week.
- **HealthKit:** reports conflict on whether free teams get it. The project therefore has a `NO_HEALTHKIT` build flag.
- **Keeping the score on screen:** without a workout session, set *Watch Settings → General → Return to Clock → Padel → After 1 hour*.

### CI/CD
- **`ci.yml`** runs on every push:
  - `swift test` for PadelKit on Linux, which is cheap;
  - on macOS, `xcodegen` plus an unsigned `xcodebuild` of the iOS app with the watch app embedded.
- **`testflight.yml`** runs manually, on a tag, and monthly:
  - **Archive** with `-allowProvisioningUpdates` and the API key flags. Signing is managed in the cloud, so no certificates live in the repo.
  - **Export** with `method: app-store-connect` and `destination: upload`, which uploads straight to TestFlight.
  - **Build number:** the GitHub run number. `ITSAppUsesNonExemptEncryption = NO` skips the export-compliance questions.
- **Cost:**
  - GitHub Actions is [free for public repos][ghpricing].
  - For a private repo, macOS minutes count about 10× against the 2,000 free minutes a month. That still covers roughly 15–25 builds.
  - If you ever have a Mac, [Xcode Cloud][xcodecloud] (25 hours a month included with the program) is an alternative.

---

## 7. Sharing

- **The app:**
  - Share TestFlight's **public link**, which also appears as a QR code in *Settings → Invite friends*.
  - Friends need iOS 18 or later. A watch is optional, since they can keep score on the phone.
  - For external testers, the first build of each version goes through a short Beta App Review (usually about a day).
  - You are an *internal* tester, so review never blocks you.
  - Later, a free **App Store** release makes it a one-tap install for anyone. It needs a privacy policy, which can live on GitHub Pages and simply say "no data collected".
- **Results:** share cards (square and 9:16) through the iOS share sheet to WhatsApp, Instagram or Messages, plus CSV/JSON export.
- **Live:** the courtside scoreboard on a phone or iPad. A spectator web link could come later.

---

## 8. Roadmap

Phase 0 comes first on purpose: it proves the "easy to install" part before any padel code exists.

| Phase | Deliverable | Done when |
|---|---|---|
| **0 · Pipeline** | Repo skeleton, XcodeGen project, "Hello, padel" watch + phone app, CI, TestFlight workflow | The hello-world app is on your iPhone and Ultra via TestFlight |
| **1 · Engine** | PadelKit with every rule in §3, all covered by tests | Replays of real pro matches give the right scores and servers |
| **2 · Watch MVP** | Setup, scoring, undo, serve and side, alerts, journal and resume, workout, summary | You play 3 real matches without a wrong score or a lost point |
| **3 · Phone MVP** | History, match detail, player sync, share card | A match appears on the phone and can be posted to WhatsApp |
| **4 · v0.2** | Scoreboard, Live Activity, stats, story cards, export, external TestFlight + invite QR | Friends are installing it from your link |
| **5 · v0.3** | Action Button, Double Tap, voice, complication, Always-On, changeover timer | You start a match with the Action Button and score your own points without touching the screen |

---

## 9. Testing

- **Engine** (most of the effort):
  - Table-driven tests for every rule: each deuce rule, the tie-break serve pattern, when ends change, set-start serving, and the super tie-break.
  - "Golden" full-match replays.
  - Randomized tests that check invariants on thousands of random point sequences:
    - there is always exactly one server;
    - game counts never break the rules;
    - undo returns exactly the previous state;
    - replay is deterministic.
- **UI:** SwiftUI previews for every state (deuce, star point, tie-break, match point), plus a few UI tests for the scoring loop.
- **On court:**
  - A written checklist: resume after a force-quit, taps on the dimmed screen, sweaty taps, losing the phone connection.
  - Then three real matches before sharing.

---

## 10. Risks

| Risk | Mitigation |
|---|---|
| Mis-taps or double taps with sweaty fingers | Huge zones, 0.4 s debounce, distinct haptics, one-tap unlimited undo |
| App killed mid-match (competitors' top complaint) | Journal written after every point, workout session recovery, resume on launch |
| Wrong server after players swap the order between sets | Serve-order prompt at each set start, plus "fix server" at any time |
| Rules vary from club to club | Presets, every rule configurable, table-tested engine |
| TestFlight builds expire after 90 days | Monthly scheduled CI build |
| Beta App Review delays for friends | Internal testing (you) is never blocked; friends wait about a day per version |
| Double Tap firing while you hold the racket | Opt-in, with a haptic and easy undo |
| iOS code can't be compiled on Linux / without a Mac | All app builds run on GitHub's macOS runners; the engine can be tested anywhere |
| Original Ultra (watchOS 26 at most) vs newer Ultras (watchOS 27) | Minimum watchOS 11; Double Tap only where the hardware has it |

---

## 11. Decisions needed from you

1. **Are you OK spending $99/yr** on the Apple Developer Program (Route A)? Without it, the only route is B: it needs a Mac, you re-install weekly, and you can't share.
2. **Do you have a Mac?** Route A doesn't need one, but it makes debugging on the watch faster.
3. **Which Ultra do you have** (1st gen, 2, 3 or 4)? The 1st gen has no Double Tap and stays on watchOS 26.
4. **What rules do you usually play?** Golden point, star point or advantage? A super tie-break instead of a third set? This becomes the default preset.
5. **Four player names, or just "Us vs Them"?**
6. **Public or private repo?** Public means free CI minutes, and friends could build it themselves.
7. **App name?** It must be unique in App Store Connect; a working title is fine for now.

---

## Sources

**Competitors (App Store):**
- [Padel Score Counter][pcounter]
- [Padel Watch][pwatch]
- [PadelTick][ptick]
- [Padel Pointer][ppointer]
- [PadelTracker Pro][ptracker]
- [PadelPro][ppro]
- [Padel Point][ppoint]
- [Padela][padela]
- [Padelore][padelore]
- [Tennis Padel Score Keeper][tpsk]

**Rules:**
- [FIP Rules of Padel][fiprules]
- [FIP: introducing the Star Point][fipstar]
- [Padel rules 2026 summary][rules2026]
- [Official FIP rules summary][fipsummary]

**Apple platform:**
- [Action Button docs][actionbtn]
- [Action Button example][actionbtnex]
- [What's new in watchOS 11 (Double Tap)][wwdc24]
- [watchOS 27 release and supported devices][watchos27]
- [2026 upload SDK requirement][sdkreq]
- [No padel workout type][nopadeltype]

**Distribution:**
- [Membership comparison][memberships]
- [Enrolling from the Apple Developer app][enroll]
- [TestFlight][testflight]
- [Xcode Cloud hours][xcodecloud]
- [Cloud signing in Xcode][cloudsigning]
- [GitHub Actions runner pricing][ghpricing]
- [Sideloading on Apple Watch][sideload]

[pcounter]: https://apps.apple.com/us/app/padel-score-counter/id6443920285
[pwatch]: https://apps.apple.com/us/app/padel-watch-padel-scorekeeper/id6443518532
[ptick]: https://apps.apple.com/us/app/padel-tracker-padeltick/id6744892176
[ppointer]: https://apps.apple.com/us/app/padel-pointer-score-tracker/id6757132333
[ptracker]: https://apps.apple.com/us/app/padelmate-score-tracker/id6747823428
[ppro]: https://apps.apple.com/us/app/padel-score-tracker-padelpro/id6758962753
[ppoint]: https://apps.apple.com/us/app/padel-point-track-your-score/id6743722817
[padela]: https://apps.apple.com/us/app/padela-padel-scores-and-stats/id6758765114
[padelore]: https://apps.apple.com/us/app/padelore-watch-scorekeeper/id6778968043
[tpsk]: https://apps.apple.com/us/app/tennis-padel-score-keeper/id6756925523
[fiprules]: https://www.padelfip.com/wp-content/uploads/2025/12/FIP_Rules-of-Padel.pdf
[fipstar]: https://www.padelfip.com/2025/12/between-innovation-and-tradition-introducing-the-star-point-the-scoring-system-that-appeals-to-everyone/
[rules2026]: https://padel-rules.com/basic-rules/padel-rules-2026/
[fipsummary]: https://padel.how/rules/official-fip-padel-rules/
[actionbtn]: https://developer.apple.com/documentation/appintents/actionbuttonarticle
[actionbtnex]: https://github.com/KhaosT/WatchActionButtonExample
[wwdc24]: https://developer.apple.com/videos/play/wwdc2024/10205/
[watchos27]: https://www.macrumors.com/2026/09/14/apple-releases-watchos-27/
[sdkreq]: https://developer.apple.com/news/?id=ueeok6yw
[nopadeltype]: https://getpadelscore.com/guides/apple-watch-padel-workout/
[memberships]: https://developer.apple.com/support/compare-memberships/
[enroll]: https://developer.apple.com/help/account/membership/enrolling-in-the-app/
[testflight]: https://developer.apple.com/testflight/
[xcodecloud]: https://developer.apple.com/news/?id=ik9z4ll6
[cloudsigning]: https://developer.apple.com/videos/play/wwdc2021/10204/
[ghpricing]: https://docs.github.com/en/billing/reference/actions-runner-pricing
[sideload]: https://kenhv.com/blog/sideloading-on-any-apple-product
