# PuzzleMix Mobile

PuzzleMix is a Flutter casual puzzle collection built for Android and prepared for Google Play.

## Current Play candidate

- Version: **0.6.1+8**
- Permanent package ID: **com.mehedi.puzzlemix**
- Target: **Android 16 / API 36**
- Distribution build: **Android App Bundle (AAB)**
- Release signing: permanent upload-key workflow prepared

## Game modes

- **Fruit Sort Deluxe** — premium fruit sorting in glass jars
- **Arrow Escape** — clear arrows only when their path is open
- **Color Crew** — match colored crew pieces and blocks
- **Daily Harvest** — daily Fruit Sort challenge

## Player experience

PuzzleMix includes a deep-green premium visual system, custom fruit artwork, sound effects and background music, haptic feedback, coins/stars, hints, undo/restart helpers, level progression, tutorials, and celebration effects.

## Privacy

The current candidate has no ads, analytics, account system, location, camera, microphone, or developer-controlled cloud data. Game progress is stored locally.

See:

- `PRIVACY_POLICY.md`
- `DATA_SAFETY.md`
- `PLAY_STORE_LISTING.md`
- `PLAY_STORE_CHECKLIST.md`

## CI

- **Verify PuzzleMix Source** checks the Play configuration, runs Flutter analyze, and builds a debug smoke APK.
- **Build Play Store AAB** builds the signed AAB and signed test APK after the permanent signing secrets are connected.

Never commit keystores, passwords, or GitHub secret values.
