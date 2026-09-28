#!/usr/bin/env bash
set -euo pipefail

# Final Android identity for the distributed Mikael Launcher APK.
# Keep Java source packages untouched; only the Android application ID is
# changed, avoiding a risky namespace-wide refactor of the upstream launcher.
python3 - <<'PY'
from pathlib import Path
import re

gradle=Path("app_pojavlauncher/build.gradle")
if gradle.exists():
    s=gradle.read_text()
    s,n=re.subn(r'(applicationId\s+")[^"]+(")', r'\1com.mikael.launcher.v3\2', s, count=1)
    if n:
        gradle.write_text(s)

for p in [
    Path("app_pojavlauncher/src/main/res/values/strings.xml"),
    Path("app_pojavlauncher/src/main/res/values/app_name.xml"),
]:
    if not p.exists():
        continue
    s=p.read_text()
    s,n=re.subn(r'(<string\s+name="(?:app_name|application_name)"[^>]*>)(.*?)(</string>)',
                r'\1Mikael Launcher V3\3', s, count=1, flags=re.S)
    if n:
        p.write_text(s)

manifest=Path("app_pojavlauncher/src/main/AndroidManifest.xml")
if manifest.exists():
    s=manifest.read_text()
    s=re.sub(r'android:label="@string/(?:app_name|application_name)"',
             'android:label="Mikael Launcher V3"', s, count=1)
    manifest.write_text(s)
PY
