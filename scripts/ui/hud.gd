extends Control
## Heads-up display: cog counter, district name, interaction prompt, toasts.

var _cogs_label: Label
var _district_label: Label
var _prompt_panel: PanelContainer
var _prompt_label: Label
var _toast_box: VBoxContainer


class GearIcon:
	extends Control
	var t := 0.0

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()

	func _draw() -> void:
		Steam.draw_gear(self, size / 2.0, size.x / 2.0 - 1.0, 10, Steam.BRASS, t * 0.4)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var status := PanelContainer.new()
	status.position = Vector2(16, 16)
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(status)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	status.add_child(row)
	var icon := GearIcon.new()
	icon.custom_minimum_size = Vector2(40, 40)
	row.add_child(icon)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	row.add_child(col)
	_cogs_label = Label.new()
	_cogs_label.add_theme_font_size_override("font_size", 22)
	_cogs_label.add_theme_color_override("font_color", Steam.BRASS_LIGHT)
	col.add_child(_cogs_label)
	_district_label = Label.new()
	_district_label.add_theme_font_size_override("font_size", 15)
	_district_label.add_theme_color_override("font_color", Steam.PARCHMENT_DIM)
	col.add_child(_district_label)

	var keys := Label.new()
	keys.text = "WASD / Arrows: move    E: interact    Tab: satchel    Esc: menu"
	keys.add_theme_font_size_override("font_size", 14)
	keys.add_theme_color_override("font_color", Color(0.94, 0.88, 0.75, 0.75))
	keys.add_theme_color_override("font_outline_color", Color.BLACK)
	keys.add_theme_constant_override("outline_size", 4)
	keys.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	keys.offset_left = -640
	keys.offset_right = -20
	keys.offset_top = 18
	keys.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(keys)

	_prompt_panel = PanelContainer.new()
	_prompt_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_prompt_panel)
	_prompt_label = Label.new()
	_prompt_label.add_theme_font_size_override("font_size", 19)
	_prompt_panel.add_child(_prompt_label)
	_prompt_panel.visible = false

	_toast_box = VBoxContainer.new()
	_toast_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_box.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_toast_box.offset_top = 96
	add_child(_toast_box)

	GameState.inventory_changed.connect(refresh)
	GameState.toast_requested.connect(toast)
	refresh()


func refresh() -> void:
	_cogs_label.text = "Brass Cogs: %d" % GameState.cogs


func set_district(district_name: String) -> void:
	_district_label.text = district_name


func set_prompt(target) -> void:
	if target == null:
		_prompt_panel.visible = false
		return
	_prompt_label.text = "[E]  " + target.prompt_text()
	_prompt_panel.visible = true
	# Re-centre now that the text width changed.
	_prompt_panel.reset_size()
	_prompt_panel.position.x = (size.x - _prompt_panel.size.x) / 2.0
	_prompt_panel.position.y = size.y - _prompt_panel.size.y - 28


func toast(text: String) -> void:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.add_theme_stylebox_override("panel", Steam.box(Steam.WOOD, Steam.BRASS_LIGHT, 2, 6, 10))
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Steam.BRASS_LIGHT)
	panel.add_child(label)
	_toast_box.add_child(panel)
	var tw := create_tween()
	tw.tween_interval(3.0)
	tw.tween_property(panel, "modulate:a", 0.0, 0.8)
	tw.tween_callback(panel.queue_free)
