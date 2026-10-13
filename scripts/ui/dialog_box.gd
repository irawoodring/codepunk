extends PanelContainer
## Bottom-of-screen dialog for NPCs, signs and gate messages.
## Lines type out; E / Space / Enter / click advances.

signal finished

var _name_label: Label
var _text: RichTextLabel
var _lines: Array = []
var _index := 0
var _on_done: Callable
var _tween: Tween


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	offset_left = 120
	offset_right = -120
	offset_top = -210
	offset_bottom = -24
	add_theme_stylebox_override("panel", Steam.box(Steam.WOOD, Steam.BRASS, 3, 8, 18))
	var col := VBoxContainer.new()
	add_child(col)
	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 22)
	_name_label.add_theme_color_override("font_color", Steam.BRASS_LIGHT)
	col.add_child(_name_label)
	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.fit_content = true
	_text.scroll_active = false
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	Steam.set_rich_text_size(_text, 20)
	col.add_child(_text)
	var more := Label.new()
	more.text = "E / Space to continue"
	more.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	more.add_theme_font_size_override("font_size", 13)
	more.add_theme_color_override("font_color", Steam.PARCHMENT_DIM)
	col.add_child(more)
	visible = false


func show_dialog(speaker: String, lines: Array, on_done: Callable = Callable()) -> void:
	if lines.is_empty():
		return
	if not visible:
		GameState.push_modal()
	_name_label.text = speaker
	_lines = lines
	_index = 0
	_on_done = on_done
	visible = true
	_show_line()


func _show_line() -> void:
	_text.text = Markdown._escape(str(_lines[_index]))
	_text.visible_ratio = 0.0
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_text, "visible_ratio", 1.0, clampf(_text.text.length() * 0.018, 0.2, 2.0))


func _advance() -> void:
	if _text.visible_ratio < 1.0:
		if _tween:
			_tween.kill()
		_text.visible_ratio = 1.0
		return
	_index += 1
	if _index < _lines.size():
		_show_line()
		return
	visible = false
	GameState.pop_modal()
	finished.emit()
	if _on_done.is_valid():
		_on_done.call()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	var advance: bool = event.is_action_pressed("interact") or event.is_action_pressed("ui_accept") \
		or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	if advance:
		get_viewport().set_input_as_handled()
		_advance()
	elif event.is_action_pressed("menu"):
		get_viewport().set_input_as_handled()
		_index = _lines.size()
		_text.visible_ratio = 1.0
		_advance()
