#!/usr/bin/env python3
"""Sanity-check every challenge and the world map.

    python tools/check_challenges.py                      # structure + starter code
    python tools/check_challenges.py --solutions DIR      # also run DIR/<id>.py

Checks that:
  * every challenge folder has meta.json, readme.md, mymodule.py, test_mymodule.py
  * meta.json has the fields the game uses
  * the starter code loads and FAILS at least one test (so the lock isn't free)
  * every challenge in world/map.json exists, and every challenge is placed on the map
  * with --solutions, each reference solution passes every test

Keep reference solutions OUTSIDE this repository so students can't find them.
"""
import argparse
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CHALLENGES = ROOT / "challenges"
HARNESS = ROOT / "python" / "harness.py"
MAP = ROOT / "world" / "map.json"
REQUIRED_FILES = ["meta.json", "readme.md", "mymodule.py", "test_mymodule.py"]
REQUIRED_META = ["title", "tier", "topic", "reward"]


def run(challenge_dir, code):
    with tempfile.TemporaryDirectory() as tmp:
        shutil.copy(challenge_dir / "test_mymodule.py", tmp)
        Path(tmp, "mymodule.py").write_text(code, encoding="utf-8")
        out = subprocess.run([sys.executable, str(HARNESS), tmp],
                             capture_output=True, text=True).stdout
    for line in out.splitlines():
        if line.startswith("@@CLOCKWORK_RESULT@@"):
            return json.loads(line[len("@@CLOCKWORK_RESULT@@"):])
    return {"status": "crash", "message": out}


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--solutions", type=Path, help="folder of <challenge_id>.py reference solutions")
    args = parser.parse_args()

    problems = []
    ids = sorted(p.name for p in CHALLENGES.iterdir() if p.is_dir())
    for cid in ids:
        d = CHALLENGES / cid
        missing = [f for f in REQUIRED_FILES if not (d / f).exists()]
        if missing:
            problems.append(f"{cid}: missing {', '.join(missing)}")
            continue
        try:
            meta = json.loads((d / "meta.json").read_text(encoding="utf-8"))
        except json.JSONDecodeError as e:
            problems.append(f"{cid}: meta.json is not valid JSON ({e})")
            continue
        for field in REQUIRED_META:
            if field not in meta:
                problems.append(f"{cid}: meta.json is missing '{field}'")

        starter = run(d, (d / "mymodule.py").read_text(encoding="utf-8"))
        if starter.get("status") != "ok":
            problems.append(f"{cid}: starter code doesn't load: {starter.get('message')}")
        elif starter["passed"] == starter["total"]:
            problems.append(f"{cid}: starter code already passes every test")
        line = f"{cid:<20} starter {starter.get('passed', '-')}/{starter.get('total', '-')}"

        if args.solutions:
            sol = args.solutions / f"{cid}.py"
            if not sol.exists():
                line += "   solution: (none)"
            else:
                result = run(d, sol.read_text(encoding="utf-8"))
                ok = result.get("status") == "ok" and result["passed"] == result["total"]
                line += f"   solution {'PASS' if ok else 'FAIL'}"
                if not ok:
                    failed = [t["name"] + ": " + t["message"] for t in result.get("tests", []) if not t["passed"]]
                    problems.append(f"{cid}: reference solution fails: {failed or result.get('message')}")
        print(line)

    world = json.loads(MAP.read_text(encoding="utf-8"))
    rows = world["rows"]
    placed = set()
    for key, entry in world["legend"].items():
        if "challenge" in entry:
            placed.add(entry["challenge"])
            if entry["challenge"] not in ids:
                problems.append(f"map legend '{key}' uses unknown challenge '{entry['challenge']}'")
        if not any(key in row for row in rows):
            problems.append(f"map legend '{key}' isn't placed anywhere on the map")
    for cid in ids:
        if cid not in placed:
            problems.append(f"{cid}: not placed on the map (add it to world/map.json's legend)")
    if len({len(r) for r in rows}) != 1:
        problems.append("map rows have different lengths")
    if sum(row.count("@") for row in rows) != 1:
        problems.append("map needs exactly one '@' player start")

    print()
    if problems:
        print("PROBLEMS:")
        for p in problems:
            print("  - " + p)
        sys.exit(1)
    print(f"All {len(ids)} challenges look good.")


if __name__ == "__main__":
    main()
