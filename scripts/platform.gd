extends Node
## Knows what the game is running on and adapts to it:
##   * is_mobile: a phone or tablet (touch is the main input).
##   * compact: the screen is small, so UI uses single-column layouts.
## Also scales the UI on mobile so text stays readable, and opens the HTML
## code editor that phone keyboards need.
##
## To try the mobile version on a computer, add ?mobile=1 to the game's URL
## (or run Godot with "-- --mobile").

signal layout_changed

## On mobile, the shorter side of the screen shows this many UI pixels
## (scaled from the screen's real size, within these bounds).
const MOBILE_MIN_SHORT_SIDE := 480.0
const MOBILE_MAX_SHORT_SIDE := 720.0

var is_web := false
var is_mobile := false
var compact := false

var _js: JavaScriptObject
var _editor_cb: JavaScriptObject
var _editor_done: Callable


func _ready() -> void:
	is_web = OS.has_feature("web")
	if is_web:
		JavaScriptBridge.eval(FileAccess.get_file_as_string("res://web/codepunk_mobile.js"), true)
		_js = JavaScriptBridge.get_interface("codepunkMobile")
		is_mobile = bool(_js.isMobile())
		_editor_cb = JavaScriptBridge.create_callback(_on_editor_closed)
	if "--mobile" in OS.get_cmdline_user_args():
		is_mobile = true
	get_window().size_changed.connect(_update_layout)
	_update_layout()


## True when code should be edited in the HTML editor instead of the canvas.
func uses_html_editor() -> bool:
	return is_web and is_mobile


## Opens the full-screen code editor. on_done is called with (code, action),
## where action is "save", "run" or "cancel".
func open_code_editor(title: String, code: String, on_done: Callable) -> void:
	_editor_done = on_done
	# Godot's own text-input helper keeps grabbing browser focus while it's
	# active, which would pull the phone keyboard away from the HTML editor.
	get_viewport().gui_release_focus()
	DisplayServer.window_set_ime_active(false)
	_js.openEditor(title, code, _editor_cb)


## Rewrites keyboard instructions for touch screens ("press E" -> "tap USE").
func controls_text(text: String) -> String:
	if not is_mobile:
		return text
	return text.replace("press E", "tap USE").replace("Press E", "Tap USE")


func _on_editor_closed(args: Array) -> void:
	if _editor_done.is_valid() and args.size() >= 2:
		_editor_done.call(str(args[0]), str(args[1]))


func _update_layout() -> void:
	var win := get_window()
	if is_mobile:
		var screen := Vector2(win.size)
		var short_side: float = maxf(1.0, minf(screen.x, screen.y))
		var dpr: float = float(_js.devicePixelRatio()) if is_web else 1.0
		var target := clampf(short_side / dpr * 1.25, MOBILE_MIN_SHORT_SIDE, MOBILE_MAX_SHORT_SIDE)
		var virtual_size := screen * (target / short_side)
		win.content_scale_size = Vector2i(roundi(virtual_size.x), roundi(virtual_size.y))
	var was := compact
	compact = is_mobile or get_viewport().get_visible_rect().size.x < 1000.0
	if was != compact or is_mobile:
		layout_changed.emit()
