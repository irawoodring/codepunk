extends Node
## Loads challenges from res://challenges/<id>/.
##
## Each challenge folder holds:
##   meta.json          title, tier, topic, cogs, reward, hints
##   readme.md          the problem description shown to the student
##   mymodule.py        starter code
##   test_mymodule.py   pytest-style tests (run by python/harness.py)

const ROOT := "res://challenges/"

var _cache: Dictionary = {}


func get_challenge(id: String) -> Dictionary:
	if _cache.has(id):
		return _cache[id]
	var dir := ROOT + id + "/"
	var meta = JSON.parse_string(_read(dir + "meta.json"))
	if typeof(meta) != TYPE_DICTIONARY:
		push_error("Challenge '%s' is missing or has a broken meta.json" % id)
		meta = {"title": id, "tier": "?", "topic": ""}
	meta["id"] = id
	meta["readme"] = _read(dir + "readme.md")
	meta["starter"] = _read(dir + "mymodule.py")
	meta["tests"] = _read(dir + "test_mymodule.py")
	_cache[id] = meta
	return meta


func _read(path: String) -> String:
	if not FileAccess.file_exists(path):
		push_error("Missing challenge file: " + path)
		return ""
	return FileAccess.get_file_as_string(path)
