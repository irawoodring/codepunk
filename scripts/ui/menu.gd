extends Control
## Title screen and pause menu (same panel, different buttons), including
## whether Python (Pyodide) has finished loading.

signal start_requested(new_game: bool)

var title_mode := true

var _heading: Label
var _sub: Label
var _continue: Button
var _new_game: Button
var _resume: Button
var _reset: Button
var _python_status: Label
var _confirm_reset := false
var _bg: ColorRect
var _frame: PanelContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_bg = ColorRect.new()
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var frame := PanelContainer.new()
	_frame = frame
	frame.custom_minimum_size = Vector2(620, 0)
	frame.add_theme_stylebox_override("panel", Steam.box(Steam.WOOD, Steam.BRASS, 4, 10, 28))
	center.add_child(frame)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	frame.add_child(col)

	_heading = Label.new()
	_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_heading.add_theme_font_size_override("font_size", 52)
	_heading.add_theme_color_override("font_color", Steam.BRASS_LIGHT)
	_heading.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_heading.add_theme_constant_override("shadow_offset_y", 3)
	col.add_child(_heading)
	_sub = Label.new()
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sub.add_theme_color_override("font_color", Steam.PARCHMENT_DIM)
	col.add_child(_sub)
	col.add_child(HSeparator.new())

	_continue = _button(col, "Continue", func(): _start(false))
	_new_game = _button(col, "New Game", _on_new_game)
	_resume = _button(col, "Resume", hide_menu)
	_reset = _button(col, "Reset All Progress", _on_reset)
	var quit := _button(col, "Quit", func(): get_tree().quit())
	quit.visible = not OS.has_feature("web")  # closing the tab is how you quit a web game

	col.add_child(HSeparator.new())
	_python_status = Label.new()
	_python_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_python_status.add_theme_font_size_override("font_size", 15)
	col.add_child(_python_status)
	PythonRunner.status_changed.connect(_update_python_status)


func apply_layout() -> void:
	var view := get_viewport_rect().size
	_frame.custom_minimum_size.x = minf(620.0, view.x - 20.0)
	_frame.add_theme_stylebox_override("panel",
		Steam.box(Steam.WOOD, Steam.BRASS, 4, 10, 14 if Platform.compact else 28))
	_heading.add_theme_font_size_override("font_size", 38 if Platform.compact else 52)


func _button(parent: Control, text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.pressed.connect(action)
	parent.add_child(b)
	return b


func show_title() -> void:
	title_mode = true
	_heading.text = "CODEPUNK"
	_sub.text = "The Clockwork Codex\nEvery lock in Cogsworth opens with Python. Explore the city, " \
		+ "solve the puzzle-locks, and awaken the Grand Engine."
	_bg.color = Color("120c08")
	_continue.visible = GameState.has_save()
	_new_game.visible = true
	_resume.visible = false
	_reset.visible = false
	_open()
	(_continue if _continue.visible else _new_game).grab_focus()


func show_pause() -> void:
	title_mode = false
	_heading.text = "Paused"
	_sub.text = "Your progress and code are saved automatically."
	_bg.color = Color(0, 0, 0, 0.55)
	_continue.visible = false
	_new_game.visible = false
	_resume.visible = true
	_reset.visible = true
	_reset.text = "Reset All Progress"
	_confirm_reset = false
	_open()
	_resume.grab_focus()


func _open() -> void:
	if not visible:
		GameState.push_modal()
	visible = true
	_update_python_status()


func hide_menu() -> void:
	if visible:
		visible = false
		GameState.pop_modal()


func _start(new_game: bool) -> void:
	hide_menu()
	start_requested.emit(new_game)


func _on_new_game() -> void:
	GameState.reset_progress()
	_start(true)


func _on_reset() -> void:
	if not _confirm_reset:
		_confirm_reset = true
		_reset.text = "Click again to erase everything"
		return
	GameState.reset_progress()
	get_tree().reload_current_scene.call_deferred()  # after this input event finishes


func _update_python_status() -> void:
	_python_status.text = PythonRunner.status_text()
	var colors := {"ready": Steam.VERDIGRIS, "loading": Steam.BRASS, "error": Steam.RUST}
	_python_status.add_theme_color_override("font_color", colors.get(PythonRunner.status(), Steam.PARCHMENT_DIM))


func _input(event: InputEvent) -> void:
	if visible and not title_mode and event.is_action_pressed("menu"):
		get_viewport().set_input_as_handled()
		hide_menu()
