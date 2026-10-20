"""Apply the checked-in PuzzleMix artwork after generating an Android shell."""
from pathlib import Path
import shutil

root = Path(__file__).resolve().parent.parent
source = root / "branding" / "android-res"
target = root / "android" / "app" / "src" / "main" / "res"
if not target.is_dir():
    raise SystemExit("Generate the Android shell before applying the icon")
for icon in source.rglob("*.png"):
    destination = target / icon.relative_to(source)
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(icon, destination)
print("Applied PuzzleMix fruit launcher icons")
