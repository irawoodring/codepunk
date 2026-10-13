#!/usr/bin/env python3
"""Turn a Laker Code Gym style problem folder into a Codepunk challenge.

    python tools/import_problem.py path/to/problems/tip_calculator --tier CS1

The source folder needs readme.md, mymodule.py and test_mymodule.py (the same
layout Codepunk uses). This copies them into challenges/<name>/ and writes a
starter meta.json for you to fill in. Then place the challenge on the map by
adding a letter to world/map.json's "legend" and putting that letter in "rows".
"""
import argparse
import json
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("source", type=Path, help="problem folder to import")
    parser.add_argument("--tier", default="CS1", choices=["CS1", "CS2"])
    parser.add_argument("--name", help="challenge id (defaults to the folder name)")
    args = parser.parse_args()

    src = args.source
    cid = args.name or src.name
    dest = ROOT / "challenges" / cid
    if dest.exists():
        sys.exit(f"challenges/{cid} already exists")
    for f in ["readme.md", "mymodule.py", "test_mymodule.py"]:
        if not (src / f).exists():
            sys.exit(f"{src} has no {f}")

    dest.mkdir(parents=True)
    for f in ["readme.md", "mymodule.py", "test_mymodule.py"]:
        shutil.copy(src / f, dest / f)
    first_line = (src / "readme.md").read_text(encoding="utf-8").splitlines()[0]
    title = first_line.lstrip("# ").strip() or cid
    meta = {
        "title": title,
        "tier": args.tier,
        "topic": "TODO: e.g. Loops & lists",
        "cogs": 1,
        "reward": {"item": "TODO item name", "description": "TODO flavour text", "color": "#c8a050"},
        "hints": ["TODO first nudge", "TODO bigger hint"],
    }
    (dest / "meta.json").write_text(json.dumps(meta, indent=2) + "\n", encoding="utf-8")
    print(f"Created challenges/{cid}/. Next:")
    print("  1. Fill in the TODOs in meta.json")
    print("  2. Make sure mymodule.py has a stub for every function (so the tests can import it)")
    print("  3. Add it to world/map.json and run: python tools/check_challenges.py")


if __name__ == "__main__":
    main()
