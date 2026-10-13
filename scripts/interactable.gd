class_name Interactable
extends Node2D
## Anything the player can walk up to and press E on: chests, caged relics,
## the Grand Engine, gates, people and signs. Main decides what happens via
## the `requested` signal; this node handles looks and collision.

signal requested(target: Interactable)

var kind := "chest"           # chest, relic, engine, gate, npc, sign
var data: Dictionary = {}     # legend entry (or gate entry) from map.json
var key := ""                 # the map character, e.g. "a" or "1"
var challenge: Dictionary = {}

var _time := 0.0
var _open := 0.0              # 0 = closed/locked, animates to 1 when done
var _body: StaticBody2D
var _body_shape: CollisionShape2D


func setup(p_kind: String, p_key: String, p_data: Dictionary) -> void:
	kind = p_kind
	key = p_key
	data = p_data
	if data.has("challenge"):
		challenge = Challenges.get_challenge(data["challenge"])
	_open = 1.0 if is_done() else 0.0


func _ready() -> void:
	_time = randf() * 10.0
	_body = StaticBody2D.new()
	_body_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(88, 56) if kind == "engine" else Vector2(26, 22)
	_body_shape.shape = rect
	_body_shape.position = Vector2(0, 2)
	_body.add_child(_body_shape)
	add_child(_body)
	if kind == "gate":
		rect.size = Vector2(32, 32)
		_body_shape.position = Vector2.ZERO
		if is_done():
			_body_shape.set_deferred("disabled", true)

	var area := Area2D.new()
	area.collision_layer = 2
	area.collision_mask = 0
	area.monitoring = false
	var area_shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 46.0 if kind == "engine" else 18.0
	area_shape.shape = circle
	area.add_child(area_shape)
	add_child(area)

	GameState.challenge_solved.connect(_on_solved)


func challenge_id() -> String:
	return str(data.get("challenge", ""))


func is_done() -> bool:
	match kind:
		"chest", "relic", "engine":
			return GameState.is_solved(challenge_id())
		"gate":
			return GameState.opened_gates.has(key)
		"npc":
			return GameState.talked_to.has(str(data.get("name", "")))
	return false


func can_interact() -> bool:
	return not (kind == "gate" and is_done())


func interact() -> void:
	requested.emit(self)


func prompt_text() -> String:
	var title := str(challenge.get("title", ""))
	var tier := str(challenge.get("tier", ""))
	match kind:
		"chest":
			return ("Look inside the open chest (%s)" % title) if is_done() \
				else ("Unlock the chest: %s  [%s]" % [title, tier])
		"relic":
			return ("Revisit the empty pedestal (%s)" % title) if is_done() \
				else ("Free the caged relic: %s  [%s]" % [title, tier])
		"engine":
			return "Admire the Grand Engine" if is_done() else "Awaken the Grand Engine  [%s]" % tier
		"gate":
			return "Open the %s (needs %d Brass Cogs)" % [data.get("name", "gate"), int(data.get("cogs", 0))]
		"npc":
			return "Talk to %s" % data.get("name", "someone")
		"sign":
			return "Read the sign"
	return "Interact"


## Called by Main when a gate has enough cogs.
func open_gate() -> void:
	GameState.opened_gates[key] = true
	GameState.save_game()
	_body_shape.set_deferred("disabled", true)


func _on_solved(_id: String) -> void:
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	var target := 1.0 if is_done() else 0.0
	_open = move_toward(_open, target, delta * 1.5)
	queue_redraw()


# --------------------------------------------------------------------------
# Drawing
# --------------------------------------------------------------------------

func _tier_color() -> Color:
	return Steam.TIER_COLORS.get(str(challenge.get("tier", "")), Steam.BRASS)


func _reward_color() -> Color:
	return Color(str(challenge.get("reward", {}).get("color", "#c8a050")))


func _draw() -> void:
	match kind:
		"chest":
			_draw_chest()
		"relic":
			_draw_relic()
		"engine":
			_draw_engine()
		"gate":
			_draw_gate()
		"npc":
			_draw_npc()
		"sign":
			_draw_sign()


func _draw_chest() -> void:
	draw_colored_polygon(Steam.ellipse(Vector2(0, 12), 15, 4), Color(0, 0, 0, 0.35))
	var body := Rect2(-13, -3, 26, 15)
	draw_rect(body, Color("6a4428"))
	draw_rect(body, Color("3a2416"), false, 2)
	for bx in [-9, 7]:
		draw_rect(Rect2(bx, -3, 3, 15), Steam.BRASS_DARK)
	var lift := _open * 9.0
	if _open > 0.05:
		draw_rect(Rect2(-12, -3, 24, 4), Color("140c08"))
		# Spent sparkle
		var s := 0.5 + 0.5 * sin(_time * 3.0)
		draw_circle(Vector2(-4, -5 - lift), 1.5 * s, Steam.BRASS_LIGHT)
	var lid := Rect2(-13, -12 - lift, 26, 9 - _open * 4.0)
	draw_rect(lid, Color("7a5032"))
	draw_rect(lid, Color("3a2416"), false, 2)
	for bx in [-9, 7]:
		draw_rect(Rect2(bx, lid.position.y, 3, lid.size.y), Steam.BRASS)
	if _open < 0.5:
		# Glowing puzzle-lock
		var pulse := 0.6 + 0.4 * sin(_time * 3.0)
		var tier := _tier_color()
		draw_rect(Rect2(-4, -7, 8, 9), Steam.BRASS)
		draw_circle(Vector2(0, -3), 2.2, tier * Color(1, 1, 1, pulse) + Color(0.2, 0.2, 0.2, 0))
		for i in 3:
			draw_circle(Vector2(0, -3), 6.0 + i * 4.0, Color(tier.r, tier.g, tier.b, 0.07 * pulse))


func _draw_relic() -> void:
	draw_colored_polygon(Steam.ellipse(Vector2(0, 12), 14, 4), Color(0, 0, 0, 0.35))
	# Stone pedestal
	draw_rect(Rect2(-11, 2, 22, 10), Color("6a6058"))
	draw_rect(Rect2(-13, 0, 26, 4), Color("8a8078"))
	var color := _reward_color()
	if _open < 1.0:
		var bob := sin(_time * 2.0) * 2.5
		var glow := Color(Steam.AETHER.r, Steam.AETHER.g, Steam.AETHER.b, 0.12 * (1.0 - _open))
		for i in 3:
			draw_circle(Vector2(0, -12 + bob), 8.0 + i * 5.0, glow)
		Steam.draw_gear(self, Vector2(0, -12 + bob - _open * 20.0), 7.0, 8,
			color * Color(1, 1, 1, 1.0 - _open), _time * 0.8)
	# Cage bars rise away when freed
	var rise := _open * 30.0
	var bar_alpha := 1.0 - _open
	if bar_alpha > 0.0:
		var bar := Color(Steam.BRASS.r, Steam.BRASS.g, Steam.BRASS.b, bar_alpha)
		for bx in [-10, -5, 0, 5, 10]:
			draw_line(Vector2(bx, -26 - rise), Vector2(bx, 0 - rise), bar, 1.5)
		draw_rect(Rect2(-12, -28 - rise, 24, 3), bar)
		draw_rect(Rect2(-12, -2 - rise, 24, 3), bar)


func _draw_engine() -> void:
	var lit := _open
	draw_colored_polygon(Steam.ellipse(Vector2(0, 30), 50, 10), Color(0, 0, 0, 0.35))
	# Base housing
	draw_rect(Rect2(-44, -10, 88, 40), Color("3a3238"))
	draw_rect(Rect2(-44, -10, 88, 40), Steam.BRASS_DARK, false, 3)
	for px in [-38, 30]:
		draw_rect(Rect2(px, -34, 8, 64), Steam.COPPER)
		draw_rect(Rect2(px + 2, -34, 2, 64), Steam.COPPER.lightened(0.35))
	# Gears
	var spin := _time * (0.2 + lit * 1.2)
	Steam.draw_gear(self, Vector2(-24, 8), 14, 10, Steam.BRASS, spin)
	Steam.draw_gear(self, Vector2(24, 8), 14, 10, Steam.BRASS, -spin)
	Steam.draw_gear(self, Vector2(0, 22), 9, 8, Steam.COPPER, spin * 1.5)
	# Core
	var core := Steam.AETHER.lerp(Color("2a3a40"), 1.0 - lit)
	var pulse := 0.75 + 0.25 * sin(_time * 4.0)
	for i in 4:
		draw_circle(Vector2(0, -14), 18.0 + i * 8.0,
			Color(Steam.AETHER.r, Steam.AETHER.g, Steam.AETHER.b, (0.05 + 0.08 * lit) * pulse))
	draw_circle(Vector2(0, -14), 15, Steam.BRASS_DARK)
	draw_circle(Vector2(0, -14), 12, core)
	for a in 6:
		var dir := Vector2.from_angle(a * TAU / 6.0 + _time * 0.3)
		draw_line(Vector2(0, -14) + dir * 12, Vector2(0, -14) + dir * 15, Steam.BRASS, 2)


func _draw_gate() -> void:
	var lift := _open * 30.0
	var alpha := 1.0 - _open * 0.85
	draw_rect(Rect2(-16, -16, 32, 32), Color(0.08, 0.06, 0.05, 0.9 * alpha))
	var iron := Color(0.25, 0.25, 0.28, alpha)
	for bx in range(-13, 16, 6):
		draw_rect(Rect2(bx, -16 - lift, 3, 32), iron)
	draw_rect(Rect2(-16, -6 - lift, 32, 3), iron)
	draw_rect(Rect2(-16, 6 - lift, 32, 3), iron)
	if _open < 0.5:
		Steam.draw_gear(self, Vector2(0, 0), 8, 8, Steam.BRASS, _time * 0.2)
		var need := int(data.get("cogs", 0))
		var have := GameState.cogs
		var ready_color := Steam.VERDIGRIS if have >= need else Steam.RUST
		draw_circle(Vector2(0, 0), 2.5, ready_color)


func _draw_npc() -> void:
	var foreman := str(data.get("style", "")) == "foreman"
	var bob := sin(_time * 2.0) * 0.8
	draw_colored_polygon(Steam.ellipse(Vector2(0, 14), 10, 3.5), Color(0, 0, 0, 0.35))
	var coat := Color("c06a2a") if foreman else Color("2e5a4a")
	var w := 11.0 if foreman else 9.0
	draw_colored_polygon(PackedVector2Array([Vector2(-w + 1, -6 + bob), Vector2(w - 1, -6 + bob),
		Vector2(w, 13), Vector2(-w, 13)]), coat)
	draw_rect(Rect2(-w + 1, 0 + bob, (w - 1) * 2, 2), Steam.BRASS_DARK)
	draw_circle(Vector2(0, -11 + bob), 6, Color("e0b890"))
	if foreman:
		# Welding mask pushed up and a big moustache
		draw_rect(Rect2(-7, -21 + bob, 14, 6), Color("2a2a30"))
		draw_rect(Rect2(-5, -20 + bob, 10, 2), Steam.AETHER.darkened(0.4))
		draw_rect(Rect2(-5, -9 + bob, 10, 2), Color("4a2a18"))
	else:
		# White hair, monocle and a tall hat
		draw_circle(Vector2(-5, -10 + bob), 3, Color("e8e8e8"))
		draw_circle(Vector2(5, -10 + bob), 3, Color("e8e8e8"))
		draw_rect(Rect2(-7, -17 + bob, 14, 2), Color("1e1a1c"))
		draw_rect(Rect2(-4, -26 + bob, 8, 10), Color("3a2a30"))
		draw_arc(Vector2(2.5, -11 + bob), 2.4, 0, TAU, 10, Steam.BRASS, 1.2)
		draw_line(Vector2(4.8, -11 + bob), Vector2(5.5, -4 + bob), Steam.BRASS, 0.8)
	if not is_done():
		var y := -36 + sin(_time * 4.0) * 2.0
		draw_circle(Vector2(0, y), 7, Steam.BRASS_LIGHT)
		draw_rect(Rect2(-1.2, y - 4.5, 2.4, 6), Steam.INK)
		draw_circle(Vector2(0, y + 3.5), 1.3, Steam.INK)


func _draw_sign() -> void:
	draw_colored_polygon(Steam.ellipse(Vector2(0, 13), 7, 2.5), Color(0, 0, 0, 0.35))
	draw_rect(Rect2(-2, -4, 4, 17), Color("4a3020"))
	draw_rect(Rect2(-12, -14, 24, 12), Steam.BRASS_DARK)
	draw_rect(Rect2(-10, -12, 20, 8), Steam.BRASS)
	for i in 3:
		draw_line(Vector2(-7, -10 + i * 2.5), Vector2(7, -10 + i * 2.5), Steam.BRASS_DARK, 1)
