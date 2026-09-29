#!/usr/bin/env python3
"""Print the CoreDevice identifier of the first connected iPhone or Apple Watch.

Usage: device_id.py iphone|watch
Reads the JSON written by `xcrun devicectl list devices --json-output`.
UNVERIFIED on real hardware: the JSON field names below follow devicectl's
output as documented but have not been run against a paired iPhone and Ultra.
"""
import json
import subprocess
import sys
import tempfile


def main() -> int:
    kind = sys.argv[1] if len(sys.argv) > 1 else ""
    if kind not in ("iphone", "watch"):
        print("usage: device_id.py iphone|watch", file=sys.stderr)
        return 2
    with tempfile.NamedTemporaryFile(suffix=".json") as out:
        subprocess.run(
            ["xcrun", "devicectl", "list", "devices", "--json-output", out.name],
            check=True,
            stdout=subprocess.DEVNULL,
        )
        with open(out.name) as f:
            data = json.load(f)
    candidates = []
    for dev in data.get("result", {}).get("devices", []):
        hw = dev.get("hardwareProperties", {})
        kind_str = (hw.get("deviceType", "") + " " + hw.get("marketingName", "")).lower()
        kind_str = kind_str.replace("applewatch", "watch")
        if kind not in kind_str:
            continue
        conn = dev.get("connectionProperties", {})
        tunnel = conn.get("tunnelState", "")
        paired = conn.get("pairingState", "") == "paired"
        if tunnel == "unavailable" and not paired:
            continue
        rank = 0 if tunnel == "connected" else 1
        candidates.append((rank, dev.get("identifier", "")))
    candidates.sort()
    if not candidates or not candidates[0][1]:
        return 1
    print(candidates[0][1])
    return 0


if __name__ == "__main__":
    sys.exit(main())
