# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

CleanUpMaid is a macOS app (Swift Package, SwiftUI + AppKit, macOS 13+) that locks all keyboard/trackpad/mouse input via a CGEvent tap so the user can wipe their keyboard, while a fullscreen animated maid overlay shows a countdown. Typing M-A-I-D unlocks early.

## Commands

```sh
swift build                 # debug build (compile check)
./build-app.sh              # release build + assemble CleanUpMaid.app + ad-hoc codesign
open CleanUpMaid.app        # run it
swift scripts/generate-icon.swift   # regenerate icon_1024.png (AppIcon.icns is built from it)
```

There are no tests or linters. The app bundle's Info.plist is generated inline by `build-app.sh` (heredoc) — edit it there, not in `CleanUpMaid.app/`, which is a build artifact checked into the repo.

Running the app requires Accessibility permission (System Settings → Privacy & Security → Accessibility). Re-signing changes the binary, so permission may need to be re-granted after rebuilds.

## Architecture

All source is in `Sources/CleanUpMaid/`. Two singletons coordinate everything:

- **`InputLocker`** — the low-level layer. Creates a `CGEventTap` that swallows every keyboard/mouse event, forwards keyDown keycodes to `onKeyDown` on the main thread, and re-arms the tap if macOS disables it for being "unresponsive" (`tapDisabledByTimeout`/`tapDisabledByUserInput`). Knows nothing about UI.
- **`LockController`** (ObservableObject) — the session layer. Starts/stops the lock, creates one borderless `.screenSaver`-level overlay window per `NSScreen`, runs the countdown timer, and tracks unlock progress by matching keycodes against the M-A-I-D sequence (virtual keycodes `[46, 0, 34, 2]`). Both `ContentView` (control window) and `LockScreenView` (overlay) observe it.

`main.swift` has no `@main`/SwiftUI App — it's a manual `NSApplication` + `AppDelegate` that hosts `ContentView` in an `NSWindow` and ends any active lock in `applicationWillTerminate`.

`MaidView.swift` contains both the `MaidCharacter` data model (the four selectable characters with colors/catchphrases/hairstyles) and the animated maid drawn entirely with SwiftUI shapes — no image assets. The selected character is shared between the control window and the lock overlay via `@AppStorage("selectedMaid")`.

## Safety invariant

The M-A-I-D escape sequence must always work while locked — never ship a lock path where `onKeyDown` isn't wired up before input is blocked, and keep the event-tap re-arm logic intact, since a dead tap with no unlock path traps the user until the timer expires (or forces a reboot if the timer is gone too).
