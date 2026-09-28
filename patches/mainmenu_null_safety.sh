#!/usr/bin/env bash
set -euo pipefail
FILE="app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java"
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java")
s=p.read_text()
for name in ["controls","settings","news","discord","logs","files","install","modLibrary","contentLibrary","forgeOptiFine","profile","play"]:
    s=s.replace(f"  {name}.setOnClickListener(", f"  if ({name} != null) {name}.setOnClickListener(")
s=s.replace("  install.setOnLongClickListener(", "  if (install != null) install.setOnLongClickListener(")
p.write_text(s)
PY
