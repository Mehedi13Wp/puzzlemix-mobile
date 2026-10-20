"""Restore release JNI rules after creating an ignored Android platform shell."""
from pathlib import Path
import shutil

root = Path(__file__).resolve().parent.parent
app = root / "android" / "app"
if not app.is_dir():
    raise SystemExit("Generate the Android shell before applying release rules")
shutil.copy2(root / "tools/release-config/proguard-rules.pro", app / "proguard-rules.pro")
print("Applied Pigeon JNI Kotlin release keep rules")
