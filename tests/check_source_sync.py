#!/usr/bin/env python3
"""Basic consistency checks; cannot replace Roblox Studio runtime tests."""
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[1]
GEN = (ROOT / "studio" / "GenerateATV.server.luau").read_text(encoding="utf-8")
sources = {
    "Config": "src/ReplicatedStorage/ATV/Config.luau",
    "Engine": "src/ServerScriptService/ATV/Engine.luau",
    "Steering": "src/ServerScriptService/ATV/Steering.luau",
    "Suspension": "src/ServerScriptService/ATV/Suspension.luau",
    "Tires": "src/ServerScriptService/ATV/Tires.luau",
    "VisualRig": "src/ServerScriptService/ATV/VisualRig.luau",
    "VehicleController": "src/ServerScriptService/ATV/VehicleController.server.luau",
    "ATVClient": "src/StarterPlayerScripts/ATVClient.client.luau",
}
failed = False
for name, path in sources.items():
    content = (ROOT / path).read_text(encoding="utf-8")
    # The generated installer uses JSON string literals for exact source contents.
    pattern = r'install\([^\n]+?,\s*"' + re.escape(name) + r'",\s*"(?:ModuleScript|Script|LocalScript)",\s*("(?:\\.|[^"\\])*")\)'
    found = re.search(pattern, GEN)
    if not found:
        print(f"FAIL: missing embedded source: {name}")
        failed = True
        continue
    embedded = json.loads(found.group(1))
    if embedded != content:
        print(f"FAIL: out-of-sync embedded source: {name}")
        failed = True
    else:
        print(f"PASS: {name} source matches generated installer")
asset = json.loads((ROOT / "assets" / "ATV_geometry.json").read_text(encoding="utf-8"))
assert set(asset["wheel_centers_blender"]) == {"FL", "FR", "RL", "RR"}
if not failed:
    print("Static checks passed; Studio driving/physics still untested.")
else:
    raise SystemExit(1)
