from pathlib import Path
import re
import sys

PACKAGE = "com.mehedi.puzzlemix"
TARGET_API = 36

gradle = Path("android/app/build.gradle.kts")
manifest = Path("android/app/src/main/AndroidManifest.xml")
skip_signing = "--skip-signing" in sys.argv

if not gradle.exists():
    raise SystemExit("android/app/build.gradle.kts not found")

text = gradle.read_text(encoding="utf-8")

text = text.replace(
    "compileSdk = flutter.compileSdkVersion",
    f"compileSdk = {TARGET_API}",
)
text = text.replace(
    "targetSdk = flutter.targetSdkVersion",
    f"targetSdk = {TARGET_API}",
)

# The Play package ID is permanent once the app is created in Play Console.
text = re.sub(
    r'namespace\s*=\s*"[^"]+"',
    f'namespace = "{PACKAGE}"',
    text,
    count=1,
)
text = re.sub(
    r'applicationId\s*=\s*"[^"]+"',
    f'applicationId = "{PACKAGE}"',
    text,
    count=1,
)

if not skip_signing:
    release_signing = """    signingConfigs {
        create("release") {
            val keyProperties = java.util.Properties()
            val keyPropertiesFile = rootProject.file("key.properties")
            keyProperties.load(java.io.FileInputStream(keyPropertiesFile))
            keyAlias = keyProperties["keyAlias"] as String
            keyPassword = keyProperties["keyPassword"] as String
            storeFile = file(keyProperties["storeFile"] as String)
            storePassword = keyProperties["storePassword"] as String
        }
    }

"""

    if 'create("release")' not in text:
        marker = "    buildTypes {"
        if marker not in text:
            raise SystemExit("Could not locate buildTypes block")
        text = text.replace(marker, release_signing + marker, 1)

    text = text.replace(
        'signingConfig = signingConfigs.getByName("debug")',
        'signingConfig = signingConfigs.getByName("release")',
    )

    if 'signingConfig = signingConfigs.getByName("release")' not in text:
        raise SystemExit("Release signing config was not applied")

if f'namespace = "{PACKAGE}"' not in text:
    raise SystemExit("Play namespace was not applied")
if f'applicationId = "{PACKAGE}"' not in text:
    raise SystemExit("Play applicationId was not applied")
if f"compileSdk = {TARGET_API}" not in text:
    raise SystemExit("compileSdk 36 was not applied")
if f"targetSdk = {TARGET_API}" not in text:
    raise SystemExit("targetSdk 36 was not applied")

gradle.write_text(text, encoding="utf-8")

if manifest.exists():
    m = manifest.read_text(encoding="utf-8")
    m = m.replace('android:label="puzzlemix"', 'android:label="PuzzleMix"')
    m = m.replace('android:label="puzzlemix_mobile"', 'android:label="PuzzleMix"')
    manifest.write_text(m, encoding="utf-8")

print("Configured Android for Google Play:")
print(f"- package: {PACKAGE}")
print(f"- compileSdk: {TARGET_API}")
print(f"- targetSdk: {TARGET_API}")
print(
    "- release signing: skipped for source verification"
    if skip_signing
    else "- release signing: permanent upload keystore"
)
