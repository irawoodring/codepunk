extends Node2D
## Builds the game: world, player, interactables and UI, and routes
## interactions between them.

const WorldScript := preload("res://scripts/world.gd")
const AmbientScript := preload("res://scripts/ambient.gd")
const PlayerScript := preload("res://scripts/player.gd")
const HudScript := preload("res://scripts/ui/hud.gd")
const DialogScript := preload("res://scripts/ui/dialog_box.gd")
const PanelScript := preload("res://scripts/ui/challenge_panel.gd")
const SatchelScript := preload("res://scripts/ui/satchel.gd")
const MenuScript := preload("res://scripts/ui/menu.gd")

const MAP_PATH := "res://world/map.json"

var world
var player
var hud
var dialog
var panel
var satchel
var menu
var _district := ""
var _playing := false


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("120c08"))

	world = WorldScript.new()
	add_child(world)
	world.load_map(MAP_PATH)

	var entities := Node2D.new()
	entities.name = "Entities"
	entities.y_sort_enabled = true
	add_child(entities)

	var ambient = AmbientScript.new()
	ambient.vents = world.vents
	ambient.lamps = world.lamps
	ambient.z_index = 10
	add_child(ambient)

	var tint := CanvasModulate.new()
	tint.color = Color(1.0, 0.93, 0.84)
	add_child(tint)

	for obj in world.objects():
		entities.add_child(_spawn_object(obj["char"], obj["tile"]))

	player = PlayerScript.new()
	var start: Vector2i = GameState.player_tile if GameState.player_tile != null else world.start_tile
	player.position = world.tile_center(start)
	entities.add_child(player)
	player.add_camera(world.pixel_size())
	player.focus_changed.connect(_on_focus_changed)

	_build_ui()
	GameState.challenge_solved.connect(_on_challenge_solved)

	var autosave := Timer.new()
	autosave.wait_time = 5.0
	autosave.autostart = true
	autosave.timeout.connect(_remember_position)
	add_child(autosave)

	if GameState.skip_title:
		GameState.skip_title = false
		_begin()
	else:
		menu.show_title()


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = Steam.make_theme()
	layer.add_child(root)

	hud = HudScript.new()
	root.add_child(hud)
	dialog = DialogScript.new()
	root.add_child(dialog)
	panel = PanelScript.new()
	root.add_child(panel)
	panel.closed.connect(_on_panel_closed)
	satchel = SatchelScript.new()
	root.add_child(satchel)
	satchel.configure(world.districts, world.legend)
	menu = MenuScript.new()
	root.add_child(menu)
	menu.start_requested.connect(_on_start_requested)


func _spawn_object(c: String, tile: Vector2i) -> Interactable:
	var it := Interactable.new()
	if world.gates.has(c):
		it.setup("gate", c, world.gates[c])
	else:
		var entry: Dictionary = world.legend[c]
		it.setup(str(entry.get("type", "sign")), c, entry)
	it.position = world.tile_center(tile)
	it.requested.connect(_on_interact)
	return it


func _on_start_requested(new_game: bool) -> void:
	if new_game:
		# Rebuild the world from a clean save.
		GameState.skip_title = true
		get_tree().reload_current_scene()
		return
	_begin()


func _begin() -> void:
	_playing = true
	if GameState.talked_to.is_empty() and GameState.solved.is_empty():
		GameState.toast("Find Professor Brassbolt, the one with the '!', and press E to talk.")
	elif GameState.victory:
		GameState.toast("The Grand Engine hums contentedly. Keep practising any lock you like!")


func _process(_delta: float) -> void:
	if world == null or player == null:
		return
	var d: Dictionary = world.district_at(player.position)
	var label := "%s  (%s)" % [d.get("name", ""), d.get("tier", "")]
	if label != _district:
		_district = label
		hud.set_district(label)


func _unhandled_input(event: InputEvent) -> void:
	if not _playing or GameState.is_modal_open():
		return
	if event.is_action_pressed("menu"):
		get_viewport().set_input_as_handled()
		menu.show_pause()
	elif event.is_action_pressed("satchel"):
		get_viewport().set_input_as_handled()
		satchel.toggle()


func _on_focus_changed(target) -> void:
	hud.set_prompt(target)


func _on_interact(it: Interactable) -> void:
	_remember_position()
	match it.kind:
		"chest", "relic", "engine":
			if it.challenge.is_empty():
				return
			panel.open_challenge(it.challenge)
		"gate":
			_try_gate(it)
		"npc":
			var who := str(it.data.get("name", "Stranger"))
			dialog.show_dialog(who, it.data.get("lines", []), func():
				GameState.talked_to[who] = true
				GameState.save_game())
		"sign":
			dialog.show_dialog("Sign", [str(it.data.get("text", ""))])


func _try_gate(it: Interactable) -> void:
	var need := int(it.data.get("cogs", 0))
	var gate_name := str(it.data.get("name", "Gate"))
	if GameState.cogs >= need:
		it.open_gate()
		GameState.toast("The %s grinds open!" % gate_name)
		player.refresh_focus()
	else:
		dialog.show_dialog(gate_name, [
			"The %s is held shut by a lock with %d cog-shaped slots." % [gate_name, need],
			"You have %d Brass Cog%s. Open more puzzle-locks to earn the rest!" % [GameState.cogs, "" if GameState.cogs == 1 else "s"],
		])


func _on_challenge_solved(_id: String) -> void:
	hud.refresh()


func _on_panel_closed(_id: String, just_solved: bool) -> void:
	player.refresh_focus()
	if not just_solved:
		return
	var c: Dictionary = panel.challenge
	if c.get("final", false):
		dialog.show_dialog("The Grand Engine", [
			"The Aether Core flares blue-white. Pipes shudder. Gears that haven't turned in a century begin to spin.",
			"All across Cogsworth, lamps flicker on and whistles scream with joy. The Grand Engine is awake!",
			"Congratulations, Engineer. You've mastered everything from if-statements to breadth-first search. Professor Brassbolt would be proud.",
			"Every lock can still be reopened for practice. Thanks for playing CODEPUNK!",
		])
	else:
		GameState.toast("+%d Brass Cog%s  -  %s added to your satchel" % [
			int(c.get("cogs", 1)), "" if int(c.get("cogs", 1)) == 1 else "s",
			c.get("reward", {}).get("item", "Treasure")])
		_announce_gates()


func _announce_gates() -> void:
	for key in world.gates:
		var need := int(world.gates[key].get("cogs", 0))
		if GameState.cogs >= need and not GameState.opened_gates.has(key) \
				and not GameState.flags.has("announced_gate_" + key):
			GameState.flags["announced_gate_" + key] = true
			GameState.toast("You have enough cogs to open the %s!" % world.gates[key].get("name", "gate"))


func _remember_position() -> void:
	if _playing and player != null:
		GameState.player_tile = world.world_to_tile(player.position)
		GameState.save_game()
