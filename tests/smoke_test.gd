extends Node
## End-to-end smoke test. Loads the real game, opens a chest, runs Python
## tests through the real runner, opens a gate and checks saving.
##
##   godot --path . res://tests/smoke_test.tscn
##   godot --path . res://tests/smoke_test.tscn -- --shots=/some/folder   (also saves screenshots)
##
## Uses its own save file, so your real progress is untouched. Exits with
## code 0 on success, 1 on failure. Needs Python 3 on the PATH.

const FAKE := {
	"id": "smoke_test",
	"title": "Smoke Test",
	"tier": "CS1",
	"topic": "Testing the tester",
	"cogs": 6,
	"reward": {"item": "Test Tube", "description": "Proof that the harness works.", "color": "#7ae0f0"},
	"hints": ["Return a + b."],
	"readme": "# Smoke Test\n\nWrite `add(a, b)`.",
	"starter": "def add(a, b):\n    pass\n",
	"tests": "import pytest\nfrom mymodule import add\n\n@pytest.mark.parametrize('a,b,c', [(1, 2, 3), (2, 2, 4)])\ndef test_add(a, b, c):\n    assert add(a, b) == c\n\ndef test_bad():\n    with pytest.raises(TypeError):\n        add(1, 'x')\n",
}

var _shots := ""
var _failures := PackedStringArray()
var main


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--shots="):
			_shots = arg.substr(8)
	GameState.save_path = "user://smoke_test_save.json"
	GameState.reset_progress()
	_run.call_deferred()


func check(cond: bool, what: String) -> void:
	print(("  ok   " if cond else "  FAIL ") + what)
	if not cond:
		_failures.append(what)


func frames(n: int = 3) -> void:
	for i in n:
		await get_tree().process_frame


func shot(name: String) -> void:
	if _shots == "":
		return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(_shots.path_join(name + ".png"))


func find_object(key: String) -> Interactable:
	for n in main.get_node("Entities").get_children():
		if n is Interactable and n.key == key:
			return n
	return null


func _run() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	add_child(main)
	await frames(10)
	check(main.menu.visible, "title screen is shown")
	await shot("01_title")

	main.menu.hide_menu()
	main._begin()
	await frames(30)
	check(not GameState.is_modal_open(), "no modal open after starting")
	await shot("02_world_start")

	# Talk to the professor.
	var prof := find_object("p")
	check(prof != null, "professor exists")
	main._on_interact(prof)
	await frames(90)
	check(main.dialog.visible, "dialog opens")
	await shot("03_dialog")
	for i in 10:
		main.dialog._advance()
		main.dialog._advance()
	check(GameState.talked_to.has("Professor Brassbolt"), "talking to the professor is remembered")

	# Walk the player next to the boiler chest and open it.
	var chest := find_object("a")
	main.player.position = chest.position + Vector2(-32, 0)
	await frames(10)
	check(main.player.focus == chest, "player focuses the nearby chest")
	main._on_interact(chest)
	await frames(5)
	check(main.panel.visible, "challenge panel opens")
	check(main.panel._title.text == "Boiler Gauge", "panel shows the chest's challenge")
	main.panel.run_tests()
	var result = await PythonRunner.finished
	await frames(5)
	check(result[1].get("status") == "ok" and int(result[1].get("passed")) == 0,
		"starter code runs and fails every test (got %s)" % str(result[1].get("status")))
	await shot("04_challenge_failing")

	# Syntax errors highlight the line.
	main.panel._editor.text = "def psi_to_bar(psi)\n    return 1\n"
	main.panel.run_tests()
	result = await PythonRunner.finished
	await frames(3)
	check(result[1].get("status") == "syntax_error" and int(result[1].get("line")) == 1, "syntax errors are reported with a line")
	main.panel.close_panel()

	# Solve a fake challenge worth 6 cogs through the real runner.
	main.panel.open_challenge(FAKE)
	main.panel._editor.text = "def add(a, b):\n    return a + b\n"
	main.panel.run_tests()
	result = await PythonRunner.finished
	await frames(5)
	check(result[1].get("status") == "ok" and int(result[1].get("passed")) == 3, "correct code passes all tests")
	check(GameState.is_solved("smoke_test"), "challenge marked solved")
	check(GameState.cogs == 6, "cogs awarded")
	check(main.panel._reward_panel.visible, "reward banner shown")
	await shot("05_challenge_solved")
	main.panel.close_panel()
	await frames(5)

	# The Foundry gate now opens.
	var gate := find_object("1")
	main._on_interact(gate)
	await frames(60)
	check(GameState.opened_gates.has("1"), "gate 1 opens with enough cogs")
	check(gate._body_shape.disabled, "gate collision is disabled")
	var vault := find_object("2")
	main._on_interact(vault)
	await frames(5)
	check(not GameState.opened_gates.has("2") and main.dialog.visible, "vault stays shut without 12 cogs")
	main.dialog._advance()
	main.dialog._advance()
	main.dialog._advance()
	main.dialog._advance()

	# Satchel
	main.satchel.toggle()
	await frames(5)
	await shot("06_satchel")
	main.satchel.toggle()

	# Foundry view
	main.player.position = find_object("q").position + Vector2(40, 0)
	await frames(40)
	await shot("07_foundry")
	main.player.position = vault.position + Vector2(0, 48)
	await frames(40)
	await shot("08_vault")

	# The southern districts: gates need the right number of cogs.
	var skyport := find_object("3")
	var observatory := find_object("4")
	check(skyport != null and observatory != null, "Skyport and Observatory gates exist")
	main._on_interact(skyport)
	await frames(5)
	check(GameState.opened_gates.has("3"), "Skyport gate opens with 6 cogs (needs 4)")
	main._on_interact(observatory)
	await frames(5)
	check(not GameState.opened_gates.has("4") and main.dialog.visible, "Observatory gate stays shut without 14 cogs")
	for i in 4:
		main.dialog._advance()
	main.player.position = find_object("J").position + Vector2(40, 32)
	await frames(40)
	check(main.world.district_at(main.player.position).get("name") == "Skyport Docks", "player is in the Skyport Docks")
	await shot("09_docks")
	main.player.position = find_object("F").position + Vector2(-40, 0)
	await frames(40)
	await shot("10_docks_piers")
	main.player.position = find_object("M").position + Vector2(0, 40)
	await frames(40)
	check(main.world.district_at(main.player.position).get("name") == "Celestial Observatory", "district lookup finds the Observatory")
	await shot("11_observatory")
	main.player.position = find_object("U").position + Vector2(0, -48)
	await frames(40)
	await shot("12_observatory_dome")

	# Saving round-trips.
	GameState.save_game()
	GameState.solved.clear()
	GameState.load_game()
	check(GameState.is_solved("smoke_test") and GameState.opened_gates.has("1"), "save file round-trips")

	DirAccess.remove_absolute(ProjectSettings.globalize_path(GameState.save_path))
	print("SMOKE TEST %s (%d failure%s)" % ["PASSED" if _failures.is_empty() else "FAILED",
		_failures.size(), "" if _failures.size() == 1 else "s"])
	get_tree().quit(0 if _failures.is_empty() else 1)
