from pathlib import Path
import re
import sys

gradle = Path("android/app/build.gradle.kts")
manifest = Path("android/app/src/main/AndroidManifest.xml")

if not gradle.exists():
    raise SystemExit("android/app/build.gradle.kts not found")

text = gradle.read_text(encoding="utf-8")

text = text.replace(
    "compileSdk = flutter.compileSdkVersion",
    "compileSdk = 36",
)
text = text.replace(
    "targetSdk = flutter.targetSdkVersion",
    "targetSdk = 36",
)

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

gradle.write_text(text, encoding="utf-8")

if manifest.exists():
    m = manifest.read_text(encoding="utf-8")
    m = m.replace('android:label="puzzlemix"', 'android:label="PuzzleMix"')
    m = m.replace('android:label="puzzlemix_mobile"', 'android:label="PuzzleMix"')
    manifest.write_text(m, encoding="utf-8")

print("Configured Android for Play Store:")
print("- package: com.mehedi.puzzlemix")
print("- compileSdk: 36")
print("- targetSdk: 36")
print("- release signing: permanent upload keystore")
