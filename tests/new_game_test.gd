extends Node
## Regression test: choosing "New Game" on the title screen (even when a save
## exists) must drop the player straight into a fresh world, not show the menu
## again.
##
##   godot --headless --path . res://tests/new_game_test.tscn

var _failures := 0


func check(cond: bool, what: String) -> void:
	print(("  ok   " if cond else "  FAIL ") + what)
	if not cond:
		_failures += 1


func frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _ready() -> void:
	GameState.save_path = "user://new_game_test_save.json"
	# Pretend the player has made progress, so "Continue" is offered.
	GameState.reset_progress()
	GameState.solved["boiler_gauge"] = true
	GameState.cogs = 1
	GameState.player_tile = Vector2i(5, 5)
	GameState.save_game()

	# Load the real game as the current scene without freeing this node.
	var placeholder := Node.new()
	get_tree().root.add_child.call_deferred(placeholder)
	await get_tree().process_frame
	get_tree().current_scene = placeholder
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	await frames(20)

	var main = get_tree().current_scene
	check(main.menu.visible and main.menu.title_mode, "title screen is shown")
	check(main.menu._continue.visible, "Continue is offered when a save exists")

	main.menu._new_game.pressed.emit()
	await frames(20)
	main = get_tree().current_scene
	check(not main.menu.visible, "menu is hidden after New Game")
	check(not GameState.is_modal_open(), "player can move after New Game")
	check(GameState.cogs == 0 and GameState.solved.is_empty(), "progress was reset")
	check(main.player.position == main.world.tile_center(main.world.start_tile), "player is at the start")

	DirAccess.remove_absolute(ProjectSettings.globalize_path(GameState.save_path))
	print("NEW GAME TEST %s" % ("PASSED" if _failures == 0 else "FAILED"))
	get_tree().quit(0 if _failures == 0 else 1)
