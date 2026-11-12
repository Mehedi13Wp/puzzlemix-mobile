# PuzzleMix release workflow

The user explicitly requested this workflow be remembered on 2026-10-20.

Before recommending any updated AAB for Google Play testers:

1. Build the actual minified release configuration, including release JNI/R8
   rules. Passing a debug build alone does not establish release readiness.
2. Test that release configuration on the user's USB-connected physical phone:
   cold startup, existing saved progress, gameplay, completion/navigation, and
   app-specific Logcat errors. Test the changed features and relevant modes.
3. Verify production package identity `com.mehedi.puzzlemix`, version code,
   upload signing, artifact checksums, and applicable release checks.
4. Only after checks pass, provide the signed AAB for the user's manual upload
   to the existing Closed testing - Alpha track. Keep the tester list intact.
5. After publication, verify the actual Google Play-delivered production
   update on the phone. Distinguish this from any pre-upload DEV testing.

Google Play's app-signing certificate differs from the upload certificate.
Never uninstall production PuzzleMix or clear its data to bypass that mismatch.
If a pre-upload physical test requires the separate `com.mehedi.puzzlemix.dev`
package, use a minified release copy and explicitly disclose that it is not the
Play-delivered production app. Do not claim production validation until tested.

Keep development files and downloaded release artifacts on D:. Ask before
downloading anything unless the user has already authorized those downloads.
Preserve coins, stars, unlocked levels, and other existing player progress.

Regression context: Play version 0.6.10 (17) failed at startup with
`SharedPreferencesApiRegistrar.getAll` NoSuchMethodError in the minified
preferences JNI implementation. Version 0.6.11 (18) adds Kotlin runtime keep
rules and a DEX signature guard. Its minified DEV release passed physical phone
tests. At the time these instructions were written, its Play submission was
in review; actual Play-delivered v18 validation had not yet been completed.
