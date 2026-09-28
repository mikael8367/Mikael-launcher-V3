#!/usr/bin/env bash
set -euo pipefail
FILE="app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java"
python3 - <<'PY'
from pathlib import Path
import re
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java")
s=p.read_text()
s=re.sub(
    r'^(\s*)([A-Za-z_][A-Za-z0-9_]*)\.setOnClickListener\(',
    lambda m: f"{m.group(1)}if ({m.group(2)} != null) {m.group(2)}.setOnClickListener(",
    s, flags=re.M)
s=re.sub(
    r'^(\s*)([A-Za-z_][A-Za-z0-9_]*)\.setOnLongClickListener\(',
    lambda m: f"{m.group(1)}if ({m.group(2)} != null) {m.group(2)}.setOnLongClickListener(",
    s, flags=re.M)
p.write_text(s)
PY
