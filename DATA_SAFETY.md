# PuzzleMix 0.6.12 (19) — Play declaration review

Prepared 13 November 2026. Production package: com.mehedi.puzzlemix.
The owner confirmed the Play target audience excludes children and the AdMob consent message is published.
The app includes Google Mobile Ads 9.2.0, with UMP consent gating and a privacy-options entry point.

Before uploading, review the actual Play Console declarations against the configured SDK:

- Contains ads: Yes.
- Review collected/shared data: approximate location inferred from IP, app interactions, diagnostics and device/account identifiers.
- Review purposes: advertising, analytics and fraud prevention/security; account for the actual SDK configuration.
- Google states SDK traffic is encrypted in transit. Review optional advertising-ID handling separately.
- Do not reuse the former no-ads/no-data declarations.
- Publish the updated public privacy policy and verify the exact URL entered in Play Console.

Source: https://developers.google.com/admob/android/privacy/play-data-disclosure
The developer remains responsible for the final Console answers; this document does not assert those forms were updated.

Saved coins, stars, completed levels, tutorials and sound preferences stay on-device with the existing keys.
There is no new developer account system, server, purchase flow or Firebase analytics integration.

Release builds may be prepared with tools/check_play_readiness.py --candidate.
Without --candidate, the check also requires a release-validation record with physical minified tests and published declaration confirmation.
Do not present a candidate as ready for upload until those checks pass.
