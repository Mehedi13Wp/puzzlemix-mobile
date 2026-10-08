# PuzzleMix — Play Store Production Readiness

**Candidate:** 0.6.1+8  
**Permanent package ID:** `com.mehedi.puzzlemix`

## Source/build readiness

- [x] Flutter source passes analyzer and debug smoke build in CI
- [x] Android 16 / API 36 target is enforced for the Play build
- [x] Android App Bundle (AAB) build workflow exists
- [x] Permanent upload-key workflow exists
- [x] Signed APK is also produced for physical-device testing
- [x] AAB signature verification is configured
- [x] APK signature verification is configured
- [x] 16 KB ZIP alignment check is configured
- [x] Package ID is fixed for Google Play
- [x] Signing files are ignored by Git
- [x] Privacy policy exists in-app and in the repository
- [x] Play listing copy is prepared
- [x] Data Safety draft is prepared
- [x] Store icon and feature graphic have been prepared separately

## Account-side steps that must be completed later

- [ ] Add the four permanent signing values to GitHub Actions repository secrets
- [ ] Run **Build Play Store AAB** and download the signed AAB/APK artifact
- [ ] Keep the upload keystore backup in at least two private locations
- [ ] Enable a public privacy-policy page (the `docs/` site is ready for GitHub Pages)
- [ ] Capture real-device screenshots from the final signed build
- [ ] Create the app in Play Console using package `com.mehedi.puzzlemix`
- [ ] Complete App access, Ads, Data Safety, Content rating, Target audience and News/other applicable declarations
- [ ] Upload the AAB to Internal testing first
- [ ] Install the Play-delivered build from Internal testing and test all three game modes
- [ ] Review the Play pre-launch report
- [ ] Only then promote to production

## Do not change after Play Console app creation

Do not change the package ID `com.mehedi.puzzlemix`.

Do not generate a different upload key for normal releases. Keep using the permanent key prepared for this project. If Play App Signing is enabled, Google manages the app-signing key while this project key remains the upload key.

## Release policy

Before every new production version:

1. Increase versionCode.
2. Run source verification.
3. Build the signed AAB using the permanent upload key.
4. Re-check Data Safety if dependencies/features changed.
5. Test through an Internal testing track.
