from pathlib import Path
import re
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

# Current release intentionally avoids SDKs that would change the Data Safety answers.
for banned in (
    "google_mobile_ads",
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

print("PLAY STORE READINESS CHECK: PASS")
for item in notes:
    print(f"- {item}")
print("- Package: com.mehedi.puzzlemix")
print("- Target API: 36")
print("- AAB + permanent upload-signing workflow: configured")
print("- Privacy/listing/data-safety docs: present")
print("- Final Play Console submission still requires account-side declarations and real-device screenshots")
