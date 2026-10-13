# Codepunk: The Clockwork Codex

A steampunk exploration game, built in **Godot 4**, that teaches **Python** to CS1 and CS2 students.

Students explore the steam-powered city of Cogsworth. Every treasure chest and caged relic is sealed by a **puzzle-lock**: a programming problem with a set of tests. Make every test pass and the lock opens. You get the item, plus Brass Cogs that open gates to harder parts of the city.

![The plaza](docs/screenshots/plaza.png)
![A puzzle-lock](docs/screenshots/challenge.png)

## How it plays

| District | Level | Gate |
|---|---|---|
| **Cogsworth Commons** | CS1: arithmetic, `if`/`elif`, functions, strings, loops, lists, dictionaries, tuples, 2D grids | Open from the start |
| **Aetherforge Foundry** | CS2: classes, dunder methods, inheritance, stacks, linked lists, recursion, sorting algorithms | Foundry Gate: 6 cogs |
| **Vault of the Grand Engine** | CS2 finale: graphs and breadth-first search | Vault Door: 12 cogs |

* **Move:** WASD or arrow keys. **Interact:** E or Space. **Satchel:** Tab. **Menu:** Esc.
* In a puzzle-lock: the problem is on the left and a Python editor is on the right. **Ctrl+Enter** runs the tests.
* Each failing test says what went wrong, e.g. `Expected 'cold' but got None`. Errors and crashes highlight the line in the student's code that caused them.
* Every lock has 2–3 hints that the student can reveal one at a time.
* Code drafts, hints and progress save automatically. Solved locks can be reopened for practice.
* Students can skip a couple of CS1 locks and still reach the Foundry (6 of the 8 cogs are needed).

## Running it

1. Install [Godot 4.3+](https://godotengine.org/download) (the standard build; .NET isn't needed).
2. Install **Python 3** ([python.org](https://www.python.org/downloads/)). **pytest is _not_ required.**
3. Open `project.godot` in Godot and press **Play** (F5).

The game finds Python on its own (`python3`, `python`, `py`, plus common macOS paths). If it can't, the title screen and pause menu let you type the full path to the Python program. The status line shows which Python it's using.

### Exporting for students

`export_presets.cfg` has presets for Windows, macOS and Linux. They already include the non-Godot files the game needs (`challenges/`, `python/`, `world/`). In Godot: **Project → Export**, install the export templates if asked, then export. Students still need Python 3 installed.

## How student code is tested

`python/harness.py` runs the student's `mymodule.py` against the challenge's `test_mymodule.py`:

* It runs in a separate process with a **10-second timeout**, so an infinite loop can't freeze the game.
* It works **with or without pytest**. Without it, a built-in shim provides `pytest.approx`, `pytest.raises`, `pytest.fail` and `@pytest.mark.parametrize`.
* `assert a == b` failures are rewritten into `Expected b but got a` messages.
* Syntax errors, import errors, crashes and `RecursionError` are turned into plain-English messages with line numbers.

Student code runs as normal Python on the student's own machine, with the same permissions as any script they write in class. Nothing is sent over the network.

## Adding or changing challenges

Each challenge is a folder in `challenges/`, in the same layout as Laker Code Gym problems:

```
challenges/boiler_gauge/
  meta.json          # title, tier, topic, cogs, reward item, hints
  readme.md          # problem description shown in-game (Markdown)
  mymodule.py        # starter code: include a stub for every function!
  test_mymodule.py   # pytest-style tests
```

`meta.json`:

```json
{
  "title": "Boiler Gauge",
  "tier": "CS1",
  "topic": "Arithmetic & if/elif/else",
  "cogs": 1,
  "reward": {"item": "Pressure Gauge", "description": "Flavour text...", "color": "#d4a64a"},
  "hints": ["First nudge", "Bigger hint", "Nearly the answer"]
}
```

Add `"final": true` to the challenge that wins the game.

To import a problem from the practice site:

```sh
python tools/import_problem.py ../code_practice_site/problems/tip_calculator --tier CS1
```

To check everything (each starter loads and fails, and each challenge is on the map), optionally with reference solutions kept **outside this repo** as `<challenge_id>.py`:

```sh
python tools/check_challenges.py
python tools/check_challenges.py --solutions ~/codepunk-solutions
```

## Editing the world

The map is ASCII art in `world/map.json` (`rows`). Each character is a 32×32 tile:

| Char | Tile | Char | Tile |
|---|---|---|---|
| `#` | brick wall (solid) | `.` | cobblestone |
| `W` | canal water (solid) | `,` | moss |
| `P` | copper pipes (solid) | `=` | foundry grate |
| `X` | crate (solid) | `-` | rail track |
| `L` | lamp post (solid) | `~` | steam vent |
| `@` | player start | `1`–`9` | gates, defined in `gates` with the cogs they need |

Lowercase letters are objects defined in `legend`:

```json
"a": {"type": "chest",  "challenge": "boiler_gauge"},
"b": {"type": "relic",  "challenge": "gear_ratio"},
"o": {"type": "engine", "challenge": "steam_network"},
"p": {"type": "npc", "name": "Professor Brassbolt", "style": "professor", "lines": ["..."]},
"s": {"type": "sign", "text": "COGSWORTH PLAZA"}
```

`districts` sets the name and tier shown in the HUD for each column range of the map.

## Project layout

```
project.godot, scenes/main.tscn   entry point (the scene is built in code)
scripts/
  main.gd                 wires world, player, objects and UI together
  world.gd, ambient.gd    tile map drawing/collision, steam and lamp effects
  player.gd               movement and interaction
  interactable.gd         chests, relics, the engine, gates, NPCs, signs
  game_state.gd           progress, inventory, drafts, saving (autoload)
  challenge_library.gd    loads challenges (autoload)
  python_runner.gd        finds Python and runs the harness on a thread (autoload)
  steam.gd, markdown.gd   palette/theme/drawing helpers, Markdown -> BBCode
  ui/                     HUD, dialog box, challenge panel, satchel, menus
python/harness.py         test runner (no pytest needed)
challenges/               the 15 puzzle-locks
world/map.json            the city
tools/                    challenge checker and importer
tests/smoke_test.tscn     end-to-end test of the real game
```

All art is drawn in code, so there are no image assets to manage.

## Testing

```sh
# End-to-end: opens a chest, runs Python tests, opens a gate, checks saving.
godot --path . res://tests/smoke_test.tscn
# ...and save screenshots of each step:
godot --path . res://tests/smoke_test.tscn -- --shots=/tmp/shots
```

## Ideas for next steps

* More districts (e.g. an **Airship Docks** for file I/O and exceptions, or an **Observatory** for dictionaries of dictionaries and complexity).
* Per-test "partial credit" visuals, like gears on the lock that turn as more tests pass.
* A teacher export of student progress (`user://save.json` already has everything).
* A web build using Pyodide in place of local Python.
