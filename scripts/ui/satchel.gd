extends Control
## The player's satchel: collected items and progress through each district.

var _list: VBoxContainer
var _progress: Label
var _districts: Array = []
var _legend: Dictionary = {}
var _frame: PanelContainer
var _close: Button


class Swatch:
	extends Control
	var color := Steam.BRASS

	func _draw() -> void:
		Steam.draw_gear(self, size / 2.0, size.x / 2.0 - 2.0, 8, color)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.5)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var frame := PanelContainer.new()
	_frame = frame
	frame.custom_minimum_size = Vector2(760, 540)
	center.add_child(frame)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	frame.add_child(col)

	var title := Label.new()
	title.text = "Your Satchel"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Steam.BRASS_LIGHT)
	col.add_child(title)
	_progress = Label.new()
	_progress.add_theme_color_override("font_color", Steam.PARCHMENT_DIM)
	col.add_child(_progress)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 10)
	scroll.add_child(_list)

	var close := Button.new()
	close.text = "Close  (Tab)"
	_close = close
	close.size_flags_horizontal = Control.SIZE_SHRINK_END
	close.pressed.connect(toggle)
	col.add_child(close)


func apply_layout() -> void:
	var view := get_viewport_rect().size
	_frame.custom_minimum_size = Vector2(view.x - 16, view.y - 16) if Platform.compact else Vector2(760, 540)
	_progress.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if Platform.compact else TextServer.AUTOWRAP_OFF
	_close.text = "Close" if Platform.is_mobile else "Close  (Tab)"


func configure(districts: Array, legend: Dictionary) -> void:
	_districts = districts
	_legend = legend


func toggle() -> void:
	if visible:
		visible = false
		GameState.pop_modal()
	else:
		_refresh()
		visible = true
		GameState.push_modal()


func _refresh() -> void:
	for child in _list.get_children():
		child.queue_free()

	# Progress per tier, counted from the map's legend.
	var totals := {}
	var solved := {}
	for entry in _legend.values():
		if not entry.has("challenge"):
			continue
		var tier := str(Challenges.get_challenge(entry["challenge"]).get("tier", "?"))
		totals[tier] = int(totals.get(tier, 0)) + 1
		if GameState.is_solved(entry["challenge"]):
			solved[tier] = int(solved.get(tier, 0)) + 1
	var parts := PackedStringArray()
	for d in _districts:
		var tier := str(d.get("tier", ""))
		parts.append("%s (%s): %d / %d locks" % [d.get("name", ""), tier, int(solved.get(tier, 0)), int(totals.get(tier, 0))])
	parts.append("Brass Cogs: %d" % GameState.cogs)
	_progress.text = ("\n" if Platform.compact else "     ").join(parts)

	if GameState.inventory.is_empty():
		var empty := Label.new()
		empty.text = "Nothing yet. Open a puzzle-lock to claim its treasure!"
		empty.add_theme_color_override("font_color", Steam.PARCHMENT_DIM)
		_list.add_child(empty)
		return
	for item in GameState.inventory:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)
		var swatch := Swatch.new()
		swatch.color = Color(str(item.get("color", "#c8a050")))
		swatch.custom_minimum_size = Vector2(44, 44)
		row.add_child(swatch)
		var text := RichTextLabel.new()
		text.bbcode_enabled = true
		text.fit_content = true
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text.text = "[b][color=%s]%s[/color][/b]  [color=#b8a888](%s: %s)[/color]\n[i]%s[/i]" % [
			Markdown.HEADING_COLOR, item.get("item", "?"), item.get("tier", ""), item.get("title", ""),
			Markdown._escape(str(item.get("description", "")))]
		row.add_child(text)
		_list.add_child(row)


func _input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed("satchel") or event.is_action_pressed("menu")):
		get_viewport().set_input_as_handled()
		toggle()
