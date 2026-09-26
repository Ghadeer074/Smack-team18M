# Smack – Multiplayer Party & Bluffing Game for iOS

**Smack** is a real-time multiplayer party game for friends in the same room, designed for **Arabic-speaking Gulf users**. It's inspired by social-deduction and bluffing games. The host creates a room and friends join with a **6-digit code**. Each round, players answer a funny question and everyone **votes** for their favorite answer. Points decide the winner.

This was the final challenge at the **Apple Developer Academy** (Team 18M).

<!-- Add 2–3 screenshots or a short GIF here, e.g.:
<p align="center">
  <img src="docs/lobby.png" width="230"> <img src="docs/question.png" width="230"> <img src="docs/voting.png" width="230">
</p>
-->

## Features

- **Host or join:** create a game session or join one with a 6-digit invite code
- **Game flow:** lobby → answering (timed) → voting → results → end of game
- **Real-time multiplayer:** built on the CloudKit public database, with **CloudKit subscriptions** and push notifications for player, session and vote updates
- **Game analytics:** tracks games played and hosted, votes cast, points and round times
- **Monetization-ready data model:** purchases, subscriptions and unlockable items
- **Arabic-first design:** custom Arabic fonts (Tajawal, Lalezar), sound effects and music

## Architecture

```
SwiftUI Views ──► GameSessionViewModel (@MainActor, async/await)
                         │
                         ▼
     Managers: CloudKitManager · SubscriptionManager · AnalyticsManager · DeviceManager
                         │
                         ▼
          CloudKit Public Database (iCloud.com.Smack)
```

- **MVVM** with a single game-session view model that drives the game's state machine
- **Generic CloudKit CRUD layer:** models conform to a `CloudKitConvertible` protocol, which maps them to and from `CKRecord`
- **Centralized error handling** in `Utilities/ErrorHandling.swift`

### Data Model

`Session` · `Player` · `Question` · `Category` · `SessionQuestion` · `Answer` · `Vote` · `Device` · `Subscription` · `Purchase` · `UnlockableItem`

The full entity-relationship diagram is in [`Graduation project-ERD - Game-ERD.pdf`](./Graduation%20project-ERD%20-%20Game-ERD.pdf).

## Tech Stack

Swift · SwiftUI · CloudKit (public database, subscriptions) · Swift Concurrency (async/await, `@MainActor`) · UserNotifications · AVFoundation (audio) · MVVM

## Getting Started

**Requirements:** Xcode 26+, iOS 26+, an Apple Developer account, and a device signed in to iCloud.

```bash
git clone https://github.com/Ghadeer074/Smack-team18M.git
open Smack-team18M/Smack/Smack.xcodeproj
```

1. Set your own **Team** and **bundle identifier** under *Signing & Capabilities*.
2. Enable **iCloud → CloudKit** and create or select a container, then update the container identifier in `CloudKitManager.swift` and `SubscriptionManager.swift`.
3. In the CloudKit Console, deploy the record types listed above.
4. Build and run on two or more devices to play.

## My Contributions

- Designed the full **CloudKit database schema** and ERD
- Built the backend layer: `CloudKitManager`, `SubscriptionManager`, `AnalyticsManager`, the `GameSessionViewModel` game logic and the invite-code generator
- Resolved CloudKit deployment and indexing issues, and fixed game-state bugs (lost state, repeated questions, stuck round counts, role locking)

## Team

Ghadeer Fallatah ([@Ghadeer074](https://github.com/Ghadeer074)) · Nouf Alshawoosh ([@NoufAlshawoosh](https://github.com/NoufAlshawoosh)) · Nedaa ([@Lilnedaa](https://github.com/Lilnedaa))

#tconnect
