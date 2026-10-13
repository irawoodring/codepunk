extends Node
## Runs student code against a challenge's tests.
##
## Web build (what students use): Python runs in the browser with Pyodide,
## inside a Web Worker (see web/codepunk_python.js). Nothing to install.
##
## Godot editor / desktop (for teachers developing challenges): there's no
## browser, so the computer's own Python 3 is used as a fallback.

signal finished(challenge_id: String, result: Dictionary)
signal status_changed

const DESKTOP_CANDIDATES := [
	"python3", "python", "py",
	"/opt/homebrew/bin/python3", "/usr/local/bin/python3", "/usr/bin/python3",
]

var busy := false

var _web := false
var _js: JavaScriptObject
var _js_result_cb: JavaScriptObject
var _js_status_cb: JavaScriptObject
var _harness := ""
var _running_id := ""

# Desktop fallback state
var _thread: Thread
var _mutex := Mutex.new()
var _desktop_cmd := ""
var _desktop_version := ""


func _ready() -> void:
	_harness = FileAccess.get_file_as_string("res://python/harness.py")
	_web = OS.has_feature("web")
	if _web:
		JavaScriptBridge.eval(FileAccess.get_file_as_string("res://web/codepunk_python.js"), true)
		_js = JavaScriptBridge.get_interface("codepunkPython")
		# Keep references to the callbacks, or Godot frees them.
		_js_result_cb = JavaScriptBridge.create_callback(_on_js_result)
		_js_status_cb = JavaScriptBridge.create_callback(_on_js_status)
		_js.onStatus(_js_status_cb)
		_js.init()  # start downloading Python right away


func is_web() -> bool:
	return _web


## One line describing whether Python is ready, for menus.
func status_text() -> String:
	if _web:
		return str(_js.detail())
	var cmd := _detect_desktop_python()
	if cmd == "":
		return "Editor mode: no local Python 3 found. Export to Web (or use Run in Browser) to test with Pyodide."
	return "Editor mode: using local '%s' (Python %s). Students' web build uses Pyodide." % [cmd, _desktop_version]


## "ready", "loading" or "error".
func status() -> String:
	if _web:
		return str(_js.status())
	return "ready" if _detect_desktop_python() != "" else "error"


## Start a test run. Returns false if one is already running.
func run_tests(challenge_id: String, code: String, tests: String) -> bool:
	if busy:
		return false
	busy = true
	_running_id = challenge_id
	if _web:
		_js.run(challenge_id, _harness, code, tests, _js_result_cb)
	else:
		_run_desktop(challenge_id, code, tests)
	return true


func _finish(challenge_id: String, result: Dictionary) -> void:
	busy = false
	finished.emit(challenge_id, result)


# --------------------------------------------------------------------------
# Web (Pyodide)
# --------------------------------------------------------------------------

func _on_js_result(args: Array) -> void:
	var data = JSON.parse_string(str(args[0])) if not args.is_empty() else null
	if typeof(data) != TYPE_DICTIONARY:
		data = {"status": "crash", "message": "The test runner sent back something unexpected."}
	_finish(_running_id, data)


func _on_js_status(_args: Array) -> void:
	status_changed.emit()


# --------------------------------------------------------------------------
# Desktop fallback (Godot editor only)
# --------------------------------------------------------------------------

func _detect_desktop_python() -> String:
	_mutex.lock()
	var cached := _desktop_cmd
	_mutex.unlock()
	if cached != "":
		return cached
	for cmd in DESKTOP_CANDIDATES:
		var out: Array = []
		var code := OS.execute(cmd, ["-c", "import sys; print('%d.%d.%d' % sys.version_info[:3])"], out, true)
		var version := str(out[0]).strip_edges() if not out.is_empty() else ""
		if code == 0 and version.begins_with("3."):
			_mutex.lock()
			_desktop_cmd = cmd
			_desktop_version = version
			_mutex.unlock()
			return cmd
	return ""


func _run_desktop(challenge_id: String, code: String, tests: String) -> void:
	var run_dir := ProjectSettings.globalize_path("user://runs/" + challenge_id)
	DirAccess.make_dir_recursive_absolute(run_dir)
	_write(run_dir.path_join("mymodule.py"), code)
	_write(run_dir.path_join("test_mymodule.py"), tests)
	var harness := ProjectSettings.globalize_path("user://harness.py")
	_write(harness, _harness)
	_thread = Thread.new()
	_thread.start(_desktop_worker.bind(challenge_id, harness, run_dir))


func _desktop_worker(challenge_id: String, harness: String, run_dir: String) -> void:
	var result: Dictionary
	var py := _detect_desktop_python()
	if py == "":
		result = {
			"status": "no_python",
			"message": "You're running Codepunk from the Godot editor, which can't use Pyodide. "
				+ "Use Godot's 'Run in Browser' button (or the web export), or install Python 3 to test here.",
		}
	else:
		var out: Array = []
		var exit_code := OS.execute(py, [harness, run_dir], out, true)
		result = _parse_cli_output(out, exit_code)
	call_deferred("_desktop_done", challenge_id, result)


func _desktop_done(challenge_id: String, result: Dictionary) -> void:
	if _thread:
		_thread.wait_to_finish()
		_thread = null
	_finish(challenge_id, result)


func _parse_cli_output(out: Array, exit_code: int) -> Dictionary:
	var text := "" if out.is_empty() else str(out[0])
	for line in text.split("\n"):
		var l := line.strip_edges()
		if l.begins_with("@@CLOCKWORK_RESULT@@"):
			var data = JSON.parse_string(l.substr("@@CLOCKWORK_RESULT@@".length()))
			if typeof(data) == TYPE_DICTIONARY:
				return data
	return {
		"status": "crash",
		"message": "The test runner didn't report back (exit code %d).\n%s" % [exit_code, text.right(1500)],
	}


func _write(path: String, text: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("Couldn't write " + path)
		return
	f.store_string(text)


func _exit_tree() -> void:
	if _thread and _thread.is_started():
		_thread.wait_to_finish()
