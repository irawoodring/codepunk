extends Node
## Runs student code against a challenge's tests using the computer's own
## Python 3 (no pytest required). Work happens on a background thread so the
## game keeps animating while tests run.

signal finished(challenge_id: String, result: Dictionary)

const CANDIDATES := [
	"python3", "python", "py",
	"/opt/homebrew/bin/python3", "/usr/local/bin/python3", "/usr/bin/python3",
]

var busy := false
var detected_cmd := ""
var detected_version := ""

var _thread: Thread
var _mutex := Mutex.new()


## Find a working Python 3. Returns the command, or "" if none was found.
## Safe to call from any thread.
func detect_python() -> String:
	_mutex.lock()
	var cached := detected_cmd
	_mutex.unlock()
	if cached != "":
		return cached
	var options: Array = []
	if GameState.python_cmd.strip_edges() != "":
		options.append(GameState.python_cmd.strip_edges())
	options.append_array(CANDIDATES)
	for cmd in options:
		var version := _python_version(cmd)
		if version != "":
			_mutex.lock()
			detected_cmd = cmd
			detected_version = version
			_mutex.unlock()
			return cmd
	return ""


## Forget the detected interpreter (e.g. after the player changes the setting).
func reset_detection() -> void:
	_mutex.lock()
	detected_cmd = ""
	detected_version = ""
	_mutex.unlock()


func _python_version(cmd: String) -> String:
	var out: Array = []
	var code := OS.execute(cmd, ["-c", "import sys; print('%d.%d.%d' % sys.version_info[:3])"], out, true)
	if code != 0 or out.is_empty():
		return ""
	var text := str(out[0]).strip_edges()
	return text if text.begins_with("3.") else ""


## Start a test run. Returns false if one is already running.
func run_tests(challenge_id: String, code: String, tests: String) -> bool:
	if busy:
		return false
	busy = true
	var run_dir := ProjectSettings.globalize_path("user://runs/" + challenge_id)
	DirAccess.make_dir_recursive_absolute(run_dir)
	_write(run_dir.path_join("mymodule.py"), code)
	_write(run_dir.path_join("test_mymodule.py"), tests)
	# res:// isn't a real folder in exported games, so copy the harness out.
	var harness := ProjectSettings.globalize_path("user://harness.py")
	_write(harness, FileAccess.get_file_as_string("res://python/harness.py"))
	_thread = Thread.new()
	_thread.start(_worker.bind(challenge_id, harness, run_dir))
	return true


func _worker(challenge_id: String, harness: String, run_dir: String) -> void:
	var result: Dictionary
	var py := detect_python()
	if py == "":
		result = {
			"status": "no_python",
			"message": "Couldn't find Python 3 on this computer. Install it from python.org, "
				+ "or open the menu (Esc) and type the path to your python program.",
		}
	else:
		var out: Array = []
		var exit_code := OS.execute(py, [harness, run_dir], out, true)
		result = _parse(out, exit_code)
	call_deferred("_finish", challenge_id, result)


func _finish(challenge_id: String, result: Dictionary) -> void:
	if _thread:
		_thread.wait_to_finish()
		_thread = null
	busy = false
	finished.emit(challenge_id, result)


func _parse(out: Array, exit_code: int) -> Dictionary:
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
