extends Control
## The puzzle-lock screen: problem description and hints on the left, a
## Python code editor and test results on the right.

signal closed(challenge_id: String, just_solved: bool)

const PASS_COLOR := "#6fd8a8"
const FAIL_COLOR := "#f07a5a"
const ERROR_LINE := Color(0.85, 0.25, 0.15, 0.28)

var challenge: Dictionary = {}
var _id := ""
var _just_solved := false
var _error_line := -1

var _title: Label
var _subtitle: Label
var _readme: RichTextLabel
var _hints: RichTextLabel
var _hint_button: Button
var _editor: CodeEdit
var _run_button: Button
var _status: Label
var _output: RichTextLabel
var _reward_panel: PanelContainer
var _reward_text: RichTextLabel
var _save_timer: Timer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false

	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.6)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	var frame := PanelContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.offset_left = 28
	frame.offset_top = 22
	frame.offset_right = -28
	frame.offset_bottom = -22
	frame.add_theme_stylebox_override("panel", Steam.box(Steam.WOOD, Steam.BRASS, 4, 10, 16))
	add_child(frame)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	frame.add_child(col)

	# Header
	var header := HBoxContainer.new()
	col.add_child(header)
	var titles := VBoxContainer.new()
	titles.add_theme_constant_override("separation", 0)
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(titles)
	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 28)
	_title.add_theme_color_override("font_color", Steam.BRASS_LIGHT)
	titles.add_child(_title)
	_subtitle = Label.new()
	_subtitle.add_theme_font_size_override("font_size", 15)
	_subtitle.add_theme_color_override("font_color", Steam.PARCHMENT_DIM)
	titles.add_child(_subtitle)
	var close := Button.new()
	close.text = "Close  (Esc)"
	close.pressed.connect(close_panel)
	header.add_child(close)

	var split := HSplitContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.split_offset = 40
	col.add_child(split)

	# Left: problem + hints
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 0.9
	left.add_theme_constant_override("separation", 8)
	split.add_child(left)
	var readme_box := PanelContainer.new()
	readme_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	readme_box.add_theme_stylebox_override("panel", Steam.box(Steam.WOOD_MID, Steam.BRASS_DARK, 2, 6, 14))
	left.add_child(readme_box)
	_readme = RichTextLabel.new()
	_readme.bbcode_enabled = true
	_readme.selection_enabled = true
	Steam.set_rich_text_size(_readme, 17, 15)
	readme_box.add_child(_readme)

	var hint_row := HBoxContainer.new()
	left.add_child(hint_row)
	_hint_button = Button.new()
	_hint_button.pressed.connect(_reveal_hint)
	hint_row.add_child(_hint_button)
	_hints = RichTextLabel.new()
	_hints.bbcode_enabled = true
	_hints.fit_content = true
	_hints.custom_minimum_size = Vector2(0, 0)
	Steam.set_rich_text_size(_hints, 15, 14)
	left.add_child(_hints)

	# Right: editor + results
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 8)
	split.add_child(right)
	_editor = CodeEdit.new()
	_editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_editor.syntax_highlighter = Steam.python_highlighter()
	_editor.gutters_draw_line_numbers = true
	_editor.indent_use_spaces = true
	_editor.indent_size = 4
	_editor.indent_automatic = true
	_editor.auto_brace_completion_enabled = true
	_editor.highlight_current_line = true
	_editor.draw_tabs = false
	_editor.minimap_draw = false
	_editor.text_changed.connect(_on_code_changed)
	right.add_child(_editor)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 10)
	right.add_child(buttons)
	_run_button = Button.new()
	_run_button.text = "Run Tests  (Ctrl+Enter)"
	_run_button.add_theme_color_override("font_color", Steam.BRASS_LIGHT)
	_run_button.pressed.connect(run_tests)
	buttons.add_child(_run_button)
	var reset := Button.new()
	reset.text = "Reset Code"
	reset.tooltip_text = "Throw away your code and start again from the starter code."
	reset.pressed.connect(_reset_code)
	buttons.add_child(reset)
	_status = Label.new()
	_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_status.add_theme_color_override("font_color", Steam.PARCHMENT_DIM)
	buttons.add_child(_status)

	var out_box := PanelContainer.new()
	out_box.custom_minimum_size = Vector2(0, 200)
	out_box.add_theme_stylebox_override("panel", Steam.box(Steam.CODE_BG, Steam.BRASS_DARK, 2, 4, 10))
	right.add_child(out_box)
	_output = RichTextLabel.new()
	_output.bbcode_enabled = true
	_output.selection_enabled = true
	_output.scroll_following = false
	Steam.set_rich_text_size(_output, 15, 14)
	out_box.add_child(_output)

	# Reward banner (shown over the output when the lock opens)
	_reward_panel = PanelContainer.new()
	_reward_panel.add_theme_stylebox_override("panel", Steam.box(Color("1d3a30"), Steam.VERDIGRIS, 3, 8, 14))
	_reward_panel.visible = false
	right.add_child(_reward_panel)
	var reward_row := HBoxContainer.new()
	_reward_panel.add_child(reward_row)
	_reward_text = RichTextLabel.new()
	_reward_text.bbcode_enabled = true
	_reward_text.fit_content = true
	_reward_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reward_row.add_child(_reward_text)
	var claim := Button.new()
	claim.text = "Claim & Close"
	claim.pressed.connect(close_panel)
	reward_row.add_child(claim)

	_save_timer = Timer.new()
	_save_timer.one_shot = true
	_save_timer.wait_time = 2.0
	_save_timer.timeout.connect(GameState.save_game)
	add_child(_save_timer)

	PythonRunner.finished.connect(_on_tests_finished)


func open_challenge(c: Dictionary) -> void:
	challenge = c
	_id = str(c.get("id", ""))
	_just_solved = false
	var tier := str(c.get("tier", ""))
	_title.text = str(c.get("title", _id))
	_subtitle.text = "%s  -  %s%s" % [tier, c.get("topic", ""),
		"    (solved: practise as much as you like)" if GameState.is_solved(_id) else ""]
	_readme.text = Markdown.to_bbcode(str(c.get("readme", "")))
	_readme.scroll_to_line(0)
	var code = GameState.drafts.get(_id, null)
	_editor.text = str(code) if code != null else str(c.get("starter", ""))
	_editor.clear_undo_history()
	_editor.set_caret_line(0)
	_clear_error_line()
	_refresh_hints()
	_reward_panel.visible = false
	_status.text = ""
	_output.text = "[color=#b8a888]Write your code above, then press [b]Run Tests[/b]. " \
		+ "Every test must pass to open the lock.[/color]"
	if not visible:
		GameState.push_modal()
	visible = true
	_editor.grab_focus()


func close_panel() -> void:
	if not visible:
		return
	GameState.set_draft(_id, _editor.text)
	GameState.save_game()
	visible = false
	GameState.pop_modal()
	closed.emit(_id, _just_solved)


func run_tests() -> void:
	if PythonRunner.busy:
		return
	GameState.set_draft(_id, _editor.text)
	GameState.save_game()
	_clear_error_line()
	_run_button.disabled = true
	_status.text = "Running tests..."
	_output.text = "[color=#b8a888]The lock's gears whirr as it tests your code...[/color]"
	PythonRunner.run_tests(_id, _editor.text, str(challenge.get("tests", "")))


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ENTER, KEY_KP_ENTER] and (event.ctrl_pressed or event.meta_pressed):
			get_viewport().set_input_as_handled()
			run_tests()
		elif event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			close_panel()


func _on_code_changed() -> void:
	GameState.set_draft(_id, _editor.text)
	_save_timer.start()
	_clear_error_line()


func _reset_code() -> void:
	_editor.text = str(challenge.get("starter", ""))
	GameState.set_draft(_id, _editor.text)


# --- Hints ---

func _hint_list() -> Array:
	return challenge.get("hints", [])


func _refresh_hints() -> void:
	var hints := _hint_list()
	var shown: int = mini(int(GameState.hints_shown.get(_id, 0)), hints.size())
	var lines := PackedStringArray()
	for i in shown:
		lines.append("[color=%s]Hint %d:[/color] %s" % [Markdown.HEADING_COLOR, i + 1, Markdown._inline(str(hints[i]))])
	_hints.text = "\n".join(lines)
	_hints.visible = shown > 0
	_hint_button.visible = not hints.is_empty()
	_hint_button.disabled = shown >= hints.size()
	_hint_button.text = "Reveal a hint (%d/%d)" % [shown, hints.size()] if shown < hints.size() \
		else "All hints revealed"


func _reveal_hint() -> void:
	GameState.hints_shown[_id] = int(GameState.hints_shown.get(_id, 0)) + 1
	GameState.save_game()
	_refresh_hints()


# --- Results ---

func _on_tests_finished(challenge_id: String, result: Dictionary) -> void:
	_run_button.disabled = false
	if challenge_id != _id or not visible:
		_status.text = ""
		return
	var status := str(result.get("status", "crash"))
	var message := Markdown._escape(str(result.get("message", "")))
	match status:
		"ok":
			_show_test_results(result)
		"syntax_error":
			_status.text = "Syntax error"
			_output.text = "[color=%s][b]Python couldn't read your code.[/b][/color]\n%s\n\n" % [FAIL_COLOR, message] \
				+ "[color=#b8a888]Check the highlighted line (and the one above it) for a missing colon, " \
				+ "bracket, quote or a wrong indent.[/color]"
			_mark_error_line(int(result.get("line", 0)))
		"import_error":
			_status.text = "Your code crashed while loading"
			_output.text = "[color=%s][b]Your code couldn't be loaded.[/b][/color]\n%s" % [FAIL_COLOR, message]
			_mark_error_line(int(result.get("line", 0)))
			_append_printed(str(result.get("stdout", "")))
		"timeout":
			_status.text = "Stopped: took too long"
			_output.text = "[color=%s][b]Time's up![/b][/color]\n%s" % [FAIL_COLOR, message]
		"no_python":
			_status.text = "Python not found"
			_output.text = "[color=%s][b]Python 3 is needed to test your code.[/b][/color]\n%s" % [FAIL_COLOR, message]
		_:
			_status.text = "Something went wrong"
			_output.text = "[color=%s][b]The test runner hit a problem.[/b][/color]\n[code]%s[/code]" % [FAIL_COLOR, message]


func _show_test_results(result: Dictionary) -> void:
	var tests: Array = result.get("tests", [])
	var passed := int(result.get("passed", 0))
	var total := int(result.get("total", tests.size()))
	var all_pass := passed == total and total > 0
	_status.text = "%d / %d tests passed" % [passed, total]
	var lines := PackedStringArray()
	if all_pass:
		lines.append("[color=%s][b]All %d tests passed![/b][/color]" % [PASS_COLOR, total])
	else:
		lines.append("[color=%s][b]%d of %d tests passed.[/b][/color] Fix the failures below and try again." % [FAIL_COLOR, passed, total])
	var first_fail := true
	for t in tests:
		var name := _pretty_test_name(str(t.get("name", "")))
		if t.get("passed", false):
			lines.append("[color=%s]  PASS[/color]  %s" % [PASS_COLOR, name])
			continue
		lines.append("[color=%s]  FAIL[/color]  [b]%s[/b]" % [FAIL_COLOR, name])
		lines.append("[indent][code][color=#f0c8a8]%s[/color][/code][/indent]" % Markdown._escape(str(t.get("message", ""))))
		var printed := str(t.get("output", ""))
		if printed.strip_edges() != "":
			lines.append("[indent][color=#b8a888]Your code printed:[/color] [code]%s[/code][/indent]" % Markdown._escape(printed.strip_edges()))
		if first_fail and int(t.get("line", 0)) > 0:
			_mark_error_line(int(t.get("line", 0)))
		first_fail = false
	_output.text = "\n".join(lines)
	_output.scroll_to_line(0)
	if all_pass:
		_on_all_passed()


func _on_all_passed() -> void:
	var reward: Dictionary = challenge.get("reward", {})
	var cogs := int(challenge.get("cogs", 1))
	if GameState.is_solved(_id):
		_reward_text.text = "[color=%s][b]Still works perfectly.[/b][/color] You already claimed the %s from this lock." \
			% [PASS_COLOR, reward.get("item", "reward")]
	else:
		_just_solved = true
		GameState.solve(_id, challenge)
		_reward_text.text = ("[font_size=22][color=%s][b]The lock springs open![/b][/color][/font_size]\n" \
			+ "You obtained the [color=%s][b]%s[/b][/color]: [i]%s[/i]\n" \
			+ "[color=%s]+%d Brass Cog%s[/color]") % [PASS_COLOR, reward.get("color", "#c8a050"),
			reward.get("item", "reward"), reward.get("description", ""), Markdown.HEADING_COLOR, cogs,
			"" if cogs == 1 else "s"]
	_reward_panel.visible = true


func _append_printed(text: String) -> void:
	if text.strip_edges() != "":
		_output.text += "\n[color=#b8a888]Your code printed:[/color]\n[code]%s[/code]" % Markdown._escape(text)


func _pretty_test_name(raw: String) -> String:
	var name := raw.trim_prefix("test_").replace("_", " ")
	return name


func _mark_error_line(line: int) -> void:
	if line <= 0 or line > _editor.get_line_count():
		return
	_error_line = line - 1
	_editor.set_line_background_color(_error_line, ERROR_LINE)
	_editor.set_caret_line(_error_line)
	_editor.center_viewport_to_caret()


func _clear_error_line() -> void:
	if _error_line >= 0 and _error_line < _editor.get_line_count():
		_editor.set_line_background_color(_error_line, Color(0, 0, 0, 0))
	_error_line = -1
