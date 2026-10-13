extends Node2D
## Loads world/map.json, draws the tiles and builds wall collision.
##
## Tile legend (see README for the full list):
##   #  wall       .  cobblestone   ,  moss      =  foundry grate   -  rails
##   W  canal      P  pipes         X  crate     L  lamp post       ~  steam vent
##   @  player start   1-9  gates   a-z  objects defined in the map's "legend"

const SOLID := "#WLPX"
const FLOORS := ".,=-~"

var tile := 32
var rows: PackedStringArray = []
var legend: Dictionary = {}
var gates: Dictionary = {}
var districts: Array = []
var map_size := Vector2i.ZERO
var start_tile := Vector2i(1, 1)
var vents: Array[Vector2] = []
var lamps: Array[Vector2] = []

var _time := 0.0


func load_map(path: String) -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Couldn't read map " + path)
		return
	tile = int(data.get("tile_size", 32))
	rows = PackedStringArray(data.get("rows", []))
	legend = data.get("legend", {})
	gates = data.get("gates", {})
	districts = data.get("districts", [])
	var width := 0
	for r in rows:
		width = max(width, r.length())
	map_size = Vector2i(width, rows.size())
	for y in map_size.y:
		for x in map_size.x:
			var c := char_at(x, y)
			if c == "@":
				start_tile = Vector2i(x, y)
			elif c == "~":
				vents.append(tile_center(Vector2i(x, y)))
			elif c == "L":
				lamps.append(tile_center(Vector2i(x, y)))
	_build_collision()
	queue_redraw()


func char_at(x: int, y: int) -> String:
	if y < 0 or y >= rows.size() or x < 0 or x >= rows[y].length():
		return "#"
	return rows[y][x]


func tile_center(t: Vector2i) -> Vector2:
	return Vector2(t.x * tile + tile / 2.0, t.y * tile + tile / 2.0)


func world_to_tile(p: Vector2) -> Vector2i:
	return Vector2i(floori(p.x / tile), floori(p.y / tile))


func pixel_size() -> Vector2:
	return Vector2(map_size * tile)


func district_at(p: Vector2) -> Dictionary:
	var tx := world_to_tile(p).x
	for d in districts:
		if tx <= int(d.get("max_x", 9999)):
			return d
	return {}


## Every object (letters, digits) in the map with its tile position.
func objects() -> Array:
	var out := []
	for y in map_size.y:
		for x in map_size.x:
			var c := char_at(x, y)
			if legend.has(c) or gates.has(c):
				out.append({"char": c, "tile": Vector2i(x, y)})
	return out


func _build_collision() -> void:
	var body := StaticBody2D.new()
	body.name = "Walls"
	add_child(body)
	# Merge horizontal runs of solid tiles into single rectangles.
	for y in map_size.y:
		var x := 0
		while x < map_size.x:
			if not SOLID.contains(char_at(x, y)):
				x += 1
				continue
			var start := x
			while x < map_size.x and SOLID.contains(char_at(x, y)):
				x += 1
			var rect := RectangleShape2D.new()
			rect.size = Vector2((x - start) * tile, tile)
			var shape := CollisionShape2D.new()
			shape.shape = rect
			shape.position = Vector2((start + (x - start) / 2.0) * tile, (y + 0.5) * tile)
			body.add_child(shape)


func _process(delta: float) -> void:
	_time += delta


# --------------------------------------------------------------------------
# Drawing
# --------------------------------------------------------------------------

func _hash(x: int, y: int) -> int:
	var h := (x * 73856093) ^ (y * 19349663)
	return absi(h) % 1000


func _floor_for(x: int, y: int) -> String:
	var c := char_at(x, y)
	if FLOORS.contains(c):
		return c
	for n in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var nc := char_at(x + n.x, y + n.y)
		if ".,=".contains(nc):
			return nc
	return "."


func _is_foundry(x: int) -> bool:
	var d := district_at(Vector2(x * tile, 0))
	return d.get("tier", "CS1") == "CS2"


func _draw() -> void:
	for y in map_size.y:
		for x in map_size.x:
			var c := char_at(x, y)
			var r := Rect2(x * tile, y * tile, tile, tile)
			match c:
				"#":
					_draw_wall(r, x, y)
				"W":
					_draw_water(r, x, y)
				"P":
					_draw_floor(r, x, y, "=" if _is_foundry(x) else ".")
					_draw_pipes(r, x, y)
				_:
					_draw_floor(r, x, y, _floor_for(x, y))
					match c:
						"X":
							_draw_crate(r)
						"L":
							_draw_lamp(r)
						"~":
							_draw_vent(r)


func _draw_floor(r: Rect2, x: int, y: int, kind: String) -> void:
	var h := _hash(x, y)
	match kind:
		",":
			draw_rect(r, Color("3f4a2c"))
			for i in 4:
				var p := r.position + Vector2((h * (i + 3)) % 28 + 2, (h * (i + 7)) % 28 + 2)
				draw_circle(p, 2.0 + (h + i) % 3, Color("566a38") if i % 2 else Color("2f3a22"))
		"=", "-", "~":
			draw_rect(r, Color("34343a"))
			for i in range(0, tile, 8):
				draw_line(r.position + Vector2(0, i), r.position + Vector2(tile, i), Color("2a2a2f"), 2)
			draw_rect(Rect2(r.position + Vector2(1, 1), Vector2(tile - 2, tile - 2)), Color("44444c"), false, 1)
			if h % 3 == 0:
				draw_circle(r.position + Vector2(4, 4), 1.5, Color("6a6a72"))
			if kind == "-":
				for sx in range(4, tile, 10):
					draw_rect(Rect2(r.position + Vector2(sx, 4), Vector2(5, tile - 8)), Color("4a3524"))
				draw_rect(Rect2(r.position + Vector2(0, 8), Vector2(tile, 3)), Color("8a8a92"))
				draw_rect(Rect2(r.position + Vector2(0, 21), Vector2(tile, 3)), Color("8a8a92"))
		_:
			draw_rect(r, Color("3a2e24"))
			for i in 2:
				for j in 2:
					var v := float((h + i * 31 + j * 17) % 20) / 100.0
					var off := Vector2(((h >> (i + j)) % 3) - 1, ((h >> (i * 2 + j)) % 3) - 1)
					var stone := Rect2(r.position + Vector2(i * 16 + 1, j * 16 + 1) + off, Vector2(14, 14))
					draw_rect(stone, Color("5c4a3a").lightened(v - 0.08))


func _draw_wall(r: Rect2, x: int, y: int) -> void:
	var foundry := _is_foundry(x)
	var base := Color("3a3238") if foundry else Color("6b3a2a")
	var mortar := Color("201a1e") if foundry else Color("3a2018")
	draw_rect(r, base)
	for row in 4:
		var yy := r.position.y + row * 8
		draw_line(Vector2(r.position.x, yy), Vector2(r.end.x, yy), mortar, 2)
		var shift := 8 if (row + y) % 2 == 0 else 0
		for bx in range(shift, tile, 16):
			draw_line(Vector2(r.position.x + bx, yy), Vector2(r.position.x + bx, yy + 8), mortar, 2)
	if _hash(x, y) % 7 == 0:
		draw_rect(Rect2(r.position + Vector2(10, 9), Vector2(10, 5)), base.lightened(0.12))
	# Darken the face if the tile below is walkable, for a little depth.
	if not SOLID.contains(char_at(x, y + 1)):
		draw_rect(Rect2(r.position + Vector2(0, tile - 6), Vector2(tile, 6)), Color(0, 0, 0, 0.35))


func _draw_water(r: Rect2, x: int, y: int) -> void:
	draw_rect(r, Color("1d3a44"))
	var h := _hash(x, y)
	for i in 2:
		var p := r.position + Vector2((h * (i + 1)) % 20 + 4, 8 + i * 13)
		draw_arc(p, 5, PI * 1.1, PI * 1.9, 6, Color("4a8a9a"), 1.5)
	if char_at(x, y - 1) != "W":
		draw_rect(Rect2(r.position, Vector2(tile, 4)), Color("5a4a3a"))


func _draw_pipes(r: Rect2, x: int, y: int) -> void:
	var vertical := char_at(x, y - 1) == "P" or char_at(x, y + 1) == "P"
	vertical = vertical and char_at(x - 1, y) != "P" and char_at(x + 1, y) != "P"
	draw_rect(r, Color("2a2224"))
	var copper := Steam.COPPER
	for i in 2:
		var o := 7 + i * 13
		if vertical:
			draw_rect(Rect2(r.position + Vector2(o, 0), Vector2(9, tile)), copper.darkened(i * 0.15))
			draw_rect(Rect2(r.position + Vector2(o + 2, 0), Vector2(2, tile)), copper.lightened(0.35))
		else:
			draw_rect(Rect2(r.position + Vector2(0, o), Vector2(tile, 9)), copper.darkened(i * 0.15))
			draw_rect(Rect2(r.position + Vector2(0, o + 2), Vector2(tile, 2)), copper.lightened(0.35))
	if _hash(x, y) % 3 == 0:
		var flange := Rect2(r.position + Vector2(13, 3), Vector2(6, 26)) if not vertical \
			else Rect2(r.position + Vector2(3, 13), Vector2(26, 6))
		draw_rect(flange, Steam.BRASS_DARK)


func _draw_crate(r: Rect2) -> void:
	var c := Rect2(r.position + Vector2(3, 3), Vector2(26, 26))
	draw_rect(Rect2(c.position + Vector2(2, 3), c.size), Color(0, 0, 0, 0.35))
	draw_rect(c, Color("7a5434"))
	draw_rect(c, Color("4a3020"), false, 2)
	draw_line(c.position, c.end, Color("4a3020"), 2)
	draw_line(Vector2(c.end.x, c.position.y), Vector2(c.position.x, c.end.y), Color("4a3020"), 2)


func _draw_lamp(r: Rect2) -> void:
	var base := r.position + Vector2(16, 28)
	draw_colored_polygon(Steam.ellipse(base, 8, 3), Color(0, 0, 0, 0.35))
	draw_rect(Rect2(base + Vector2(-2, -26), Vector2(4, 26)), Color("1e1e22"))
	draw_rect(Rect2(base + Vector2(-6, -34), Vector2(12, 10)), Steam.BRASS_DARK)
	draw_rect(Rect2(base + Vector2(-4, -32), Vector2(8, 6)), Color("ffd890"))


func _draw_vent(r: Rect2) -> void:
	var c := r.get_center()
	draw_circle(c, 11, Color("1e1e22"))
	draw_arc(c, 11, 0, TAU, 20, Steam.BRASS_DARK, 2)
	for i in range(-6, 8, 4):
		draw_line(c + Vector2(i, -8), c + Vector2(i, 8), Color("3a3a40"), 2)
