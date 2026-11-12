from pathlib import Path
import re
import json
import hashlib
import sys

errors = []
notes = []

def require(condition, message):
    if not condition:
        errors.append(message)

pubspec = Path("pubspec.yaml").read_text(encoding="utf-8")
main = Path("lib/main.dart").read_text(encoding="utf-8")
config = Path("tools/configure_play_android.py").read_text(encoding="utf-8")
play_workflow = Path(".github/workflows/play-store-build.yml").read_text(encoding="utf-8")

version_match = re.search(r"^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)", pubspec, re.M)
require(version_match is not None, "pubspec version must use x.y.z+versionCode")
if version_match:
    notes.append(f"Version: {version_match.group(1)} (code {version_match.group(2)})")

require('PACKAGE = "com.mehedi.puzzlemix"' in config, "Permanent package ID is not configured")
require("TARGET_API = 36" in config, "Google Play target API 36 is not configured")
require("flutter build appbundle --release" in play_workflow, "Play workflow must build an AAB")
require("jarsigner -verify" in play_workflow, "AAB signature verification is missing")
require("apksigner" in play_workflow, "APK signature verification is missing")
require("zipalign" in play_workflow and "-P 16" in play_workflow, "16 KB alignment check is missing")

for secret in (
    "PLAY_UPLOAD_KEYSTORE_BASE64",
    "PLAY_UPLOAD_STORE_PASSWORD",
    "PLAY_UPLOAD_KEY_PASSWORD",
    "PLAY_UPLOAD_KEY_ALIAS",
):
    require(secret in play_workflow, f"Missing signing secret reference: {secret}")

require(Path("PRIVACY_POLICY.md").exists(), "PRIVACY_POLICY.md is missing")
require(Path("PLAY_STORE_LISTING.md").exists(), "PLAY_STORE_LISTING.md is missing")
require(Path("DATA_SAFETY.md").exists(), "DATA_SAFETY.md is missing")
require(Path("docs/privacy.html").exists(), "Public privacy page source is missing")
require(Path("docs/support.html").exists(), "Public support page source is missing")
require("PrivacyPolicyScreen" in main, "In-app privacy screen is missing")

# Candidate builds are allowed for physical validation; final readiness stays gated.
ads_path = Path("config/admob.production.json")
ads = json.loads(ads_path.read_text(encoding="utf-8")) if ads_path.exists() else {}
require(ads.get("enabled") is True and ads.get("package") == "com.mehedi.puzzlemix", "Production ad configuration is missing")
require(ads.get("audience") == "not-child-directed" and ads.get("consentMessagePublished") is True, "Audience/consent confirmation is missing")
require(Path("lib/ads/ad_consent.dart").exists(), "UMP consent integration is missing")
require("Ad privacy choices" in Path("lib/privacy_policy.dart").read_text(encoding="utf-8"), "Privacy options entry point is missing")
if version_match:
    require(int(version_match.group(2)) > ads.get("previousVersionCode", 0), "Version code must exceed the latest uploaded code")
candidate = "--candidate" in sys.argv
if not candidate:
    proof_path = Path("build/release-validation.json")
    proof = json.loads(proof_path.read_text()) if proof_path.exists() else {}
    require(proof.get("minifiedPhoneTestsPassed") is True, "Physical minified release validation is incomplete")
    require(proof.get("playDeclarationsConfirmed") is True, "Play declarations/public privacy URL are not confirmed")
    require(version_match is not None and proof.get("versionCode") == int(version_match.group(2)), "Release evidence must match the version code")
    bundle = Path(proof.get("aabPath", "build/missing-release.aab"))
    require(bundle.is_file(), "Validated AAB is missing")
    if bundle.is_file():
        require(hashlib.sha256(bundle.read_bytes()).hexdigest().lower() == str(proof.get("aabSha256", "")).lower(), "Release evidence must match the exact AAB checksum")
# Other unexpected SDKs also need a declaration review.
for banned in (
    "firebase_analytics",
    "firebase_crashlytics",
    "geolocator",
    "camera:",
    "permission_handler",
):
    require(banned not in pubspec, f"Review Data Safety: dependency detected: {banned}")

if errors:
    print("PLAY STORE READINESS CHECK: FAILED")
    for item in errors:
        print(f"- {item}")
    sys.exit(1)

print("PLAY STORE CANDIDATE CHECK: PASS — NOT upload approval" if candidate else "PLAY STORE READINESS CHECK: PASS")
for item in notes:
    print(f"- {item}")
print("- Package: com.mehedi.puzzlemix")
print("- Target API: 36")
print("- AAB + permanent upload-signing workflow: configured")
print("- Privacy/listing/data-safety docs: present")
print("- Final Play Console submission still requires account-side declarations and real-device screenshots")
