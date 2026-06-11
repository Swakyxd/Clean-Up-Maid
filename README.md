# CleanUpMaid 🧹✨

A tiny macOS app that locks your **keyboard, trackpad, and mouse** so you can
wipe them down — while an animated maid sweeps your screen and keeps you company.

## Run it

```sh
./build-app.sh
open CleanUpMaid.app
```

To regenerate the app icon and install to /Applications:

```sh
swift scripts/generate-icon.swift   # renders icon_1024.png
# then rebuild AppIcon.icns via sips/iconutil, or just:
./build-app.sh
cp -R CleanUpMaid.app /Applications/
```

First launch: grant **Accessibility** permission when prompted
(System Settings → Privacy & Security → Accessibility → enable CleanUpMaid),
then relaunch the app.

## How it works

- Pick a duration (30 sec – 5 min) and hit **Start Cleaning**.
- A fullscreen overlay appears on every display with the maid, sparkles, and a countdown.
- All keyboard, trackpad, and mouse input is swallowed by a CGEvent tap —
  clicks, keys, scrolling, even cursor movement.
- The lock ends when the timer runs out, or **type M-A-I-D** to unlock early
  (the letters light up on screen as you type them).

## Safety notes

- The unlock sequence (M-A-I-D) always works, even on the "until timer" lock.
- If the app quits or crashes for any reason, macOS automatically removes the
  event tap and your input comes right back.
