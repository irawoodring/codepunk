extends Node
## Global game state: progress, inventory, saved code drafts and settings.
## Everything here is saved to user://save.json.

signal inventory_changed
signal challenge_solved(id: String)
signal toast_requested(text: String)

var save_path := "user://save.json"

var solved: Dictionary = {}        # challenge id -> true
var inventory: Array = []          # [{item, description, color, challenge}]
var cogs: int = 0
var drafts: Dictionary = {}        # challenge id -> student code
var hints_shown: Dictionary = {}   # challenge id -> number of hints revealed
var opened_gates: Dictionary = {}  # gate char -> true
var talked_to: Dictionary = {}     # npc name -> true
var player_tile = null             # Vector2i or null for the map's start tile
var python_cmd: String = ""        # optional override, e.g. "C:/Python312/python.exe"
var victory: bool = false
var flags: Dictionary = {}         # misc one-time events, e.g. "announced_gate_1"
var skip_title := false            # not saved: set when restarting into a new game

var _modal_count := 0


func _ready() -> void:
	_setup_input()
	load_game()


# --- Modal tracking: the player can't move while a window is open. ---

func push_modal() -> void:
	_modal_count += 1


func pop_modal() -> void:
	_modal_count = max(0, _modal_count - 1)


func is_modal_open() -> bool:
	return _modal_count > 0


# --- Progress ---

func is_solved(id: String) -> bool:
	return solved.has(id)


func solve(id: String, challenge: Dictionary) -> void:
	if solved.has(id):
		return
	solved[id] = true
	cogs += int(challenge.get("cogs", 1))
	var reward: Dictionary = challenge.get("reward", {})
	inventory.append({
		"item": reward.get("item", "Mysterious Trinket"),
		"description": reward.get("description", ""),
		"color": reward.get("color", "#c8a050"),
		"challenge": id,
		"title": challenge.get("title", id),
		"tier": challenge.get("tier", ""),
	})
	if challenge.get("final", false):
		victory = true
	save_game()
	inventory_changed.emit()
	challenge_solved.emit(id)


func set_draft(id: String, code: String) -> void:
	drafts[id] = code


func toast(text: String) -> void:
	toast_requested.emit(text)


func reset_progress() -> void:
	solved.clear()
	inventory.clear()
	drafts.clear()
	hints_shown.clear()
	opened_gates.clear()
	talked_to.clear()
	flags.clear()
	cogs = 0
	player_tile = null
	victory = false
	save_game()
	inventory_changed.emit()


func has_save() -> bool:
	return FileAccess.file_exists(save_path) and (not solved.is_empty() or player_tile != null)


# --- Save / load ---

func save_game() -> void:
	var data := {
		"solved": solved.keys(),
		"inventory": inventory,
		"cogs": cogs,
		"drafts": drafts,
		"hints_shown": hints_shown,
		"opened_gates": opened_gates.keys(),
		"talked_to": talked_to.keys(),
		"player_tile": [player_tile.x, player_tile.y] if player_tile != null else null,
		"python_cmd": python_cmd,
		"victory": victory,
		"flags": flags,
	}
	var f := FileAccess.open(save_path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data, "  "))


func load_game() -> void:
	if not FileAccess.file_exists(save_path):
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(save_path))
	if typeof(data) != TYPE_DICTIONARY:
		push_warning("Save file is unreadable; starting fresh.")
		return
	for id in data.get("solved", []):
		solved[str(id)] = true
	inventory = data.get("inventory", [])
	cogs = int(data.get("cogs", 0))
	drafts = data.get("drafts", {})
	hints_shown = data.get("hints_shown", {})
	for g in data.get("opened_gates", []):
		opened_gates[str(g)] = true
	for n in data.get("talked_to", []):
		talked_to[str(n)] = true
	var pt = data.get("player_tile")
	if pt is Array and pt.size() == 2:
		player_tile = Vector2i(int(pt[0]), int(pt[1]))
	python_cmd = str(data.get("python_cmd", ""))
	victory = bool(data.get("victory", false))
	flags = data.get("flags", {})


# --- Input map (defined in code so project.godot stays readable) ---

func _setup_input() -> void:
	_add_action("move_up", [KEY_W, KEY_UP])
	_add_action("move_down", [KEY_S, KEY_DOWN])
	_add_action("move_left", [KEY_A, KEY_LEFT])
	_add_action("move_right", [KEY_D, KEY_RIGHT])
	_add_action("interact", [KEY_E, KEY_SPACE])
	_add_action("satchel", [KEY_TAB, KEY_I])
	_add_action("menu", [KEY_ESCAPE])


func _add_action(action: String, keys: Array) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)
