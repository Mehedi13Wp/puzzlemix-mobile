# PuzzleMix — Google Play Data Safety Draft

**Play candidate:** 0.6.1 (versionCode 8)  
**Package:** `com.mehedi.puzzlemix`  
**Last reviewed:** 8 October 2026

This draft reflects the current source code and dependencies. Re-check it before every production release.

## Current answers

- Does the app collect or share any required user data types? **No**
- Is all user data encrypted in transit? **Not applicable — the app does not transmit user data**
- Can users request deletion of developer-held data? **Not applicable — there is no account/server-side user data**
- Account creation: **No**
- Ads: **No**
- In-app purchases: **No**
- Analytics SDK: **No**
- Crash-reporting SDK: **No**
- Location: **No**
- Contacts: **No**
- Camera: **No**
- Microphone / audio recording: **No**
- Photos or videos: **No**
- Files/documents: **No**
- Precise device identifiers for ads/analytics: **No**

## Local-only data

PuzzleMix uses `shared_preferences` to keep game state on the device, including:

- coins
- stars
- highest unlocked level
- completed-level reward status
- tutorial status
- sound preference

This data is not sent to the developer by the current app.

## Bundled audio

The app uses locally bundled sound effects and background music through `audioplayers`. It does not request microphone or media-library access.

## Important release rule

If a future version adds ads, analytics, crash reporting, cloud saves, login/accounts, online multiplayer, push-notification SDKs, or any other external service, update this file, `PRIVACY_POLICY.md`, and the Play Console Data Safety form before release.
