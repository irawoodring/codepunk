extends CharacterBody2D
## The apprentice engineer. Moves with WASD / arrow keys and interacts with
## whatever is closest when E or Space is pressed.

signal focus_changed(target)

const SPEED := 165.0

var nearby: Array = []
var focus = null
var facing := 1.0
var _walk := 0.0
var _moving := false


func _ready() -> void:
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 8.0
	shape.shape = circle
	shape.position = Vector2(0, 6)
	add_child(shape)

	var sensor := Area2D.new()
	var sensor_shape := CollisionShape2D.new()
	var sensor_circle := CircleShape2D.new()
	sensor_circle.radius = 30.0
	sensor_shape.shape = sensor_circle
	sensor.add_child(sensor_shape)
	sensor.collision_mask = 2
	sensor.area_entered.connect(_on_area_entered)
	sensor.area_exited.connect(_on_area_exited)
	add_child(sensor)


func add_camera(limits: Vector2) -> Camera2D:
	var cam := Camera2D.new()
	cam.zoom = Vector2(1.9, 1.9)
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 6.0
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = int(limits.x)
	cam.limit_bottom = int(limits.y)
	add_child(cam)
	return cam


func _physics_process(delta: float) -> void:
	var dir := Vector2.ZERO
	if not GameState.is_modal_open():
		dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * SPEED
	move_and_slide()
	_moving = dir != Vector2.ZERO
	if dir.x != 0.0:
		facing = signf(dir.x)
	_walk = _walk + delta * 10.0 if _moving else 0.0
	queue_redraw()
	_update_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not GameState.is_modal_open() and focus != null:
		get_viewport().set_input_as_handled()
		focus.interact()


func _on_area_entered(area: Area2D) -> void:
	var owner_node := area.get_parent()
	if owner_node.has_method("interact") and not nearby.has(owner_node):
		nearby.append(owner_node)


func _on_area_exited(area: Area2D) -> void:
	nearby.erase(area.get_parent())


func _update_focus() -> void:
	var best = null
	var best_d := INF
	for n in nearby:
		if not is_instance_valid(n) or not n.can_interact():
			continue
		var d := global_position.distance_to(n.global_position)
		if d < best_d:
			best_d = d
			best = n
	if best != focus:
		focus = best
		focus_changed.emit(focus)


func refresh_focus() -> void:
	focus = null
	_update_focus()
	focus_changed.emit(focus)


func _draw() -> void:
	var bob := absf(sin(_walk)) * -2.0
	var step := sin(_walk) * 3.0
	# Shadow
	draw_colored_polygon(Steam.ellipse(Vector2(0, 14), 9, 3.5), Color(0, 0, 0, 0.35))
	# Legs
	draw_rect(Rect2(-5, 6 + bob, 4, 8 + step * 0.3), Color("2a2026"))
	draw_rect(Rect2(1, 6 + bob, 4, 8 - step * 0.3), Color("2a2026"))
	# Coat
	var coat := PackedVector2Array([
		Vector2(-8, -6 + bob), Vector2(8, -6 + bob), Vector2(10, 9 + bob), Vector2(-10, 9 + bob)])
	draw_colored_polygon(coat, Color("6a3e24"))
	draw_line(Vector2(0, -6 + bob), Vector2(0, 9 + bob), Color("4a2a18"), 1.5)
	draw_rect(Rect2(-8, 1 + bob, 16, 2), Steam.BRASS_DARK)  # belt
	draw_circle(Vector2(0, 2 + bob), 1.6, Steam.BRASS_LIGHT)
	# Arms
	draw_line(Vector2(-8, -4 + bob), Vector2(-10, 4 + bob - step * 0.5), Color("5a3420"), 3)
	draw_line(Vector2(8, -4 + bob), Vector2(10, 4 + bob + step * 0.5), Color("5a3420"), 3)
	# Head
	draw_circle(Vector2(0, -11 + bob), 6, Color("e8c4a0"))
	draw_circle(Vector2(2.5 * facing, -11 + bob), 1.2, Steam.INK)
	# Scarf
	draw_rect(Rect2(-6, -7 + bob, 12, 3), Color("9a3a30"))
	# Top hat with brass band and goggles
	draw_rect(Rect2(-8, -17 + bob, 16, 3), Color("1e1a1c"))
	draw_rect(Rect2(-5, -27 + bob, 10, 11), Color("1e1a1c"))
	draw_rect(Rect2(-5, -20 + bob, 10, 2), Steam.BRASS)
	draw_circle(Vector2(-2.5 + facing, -21.5 + bob), 2.4, Steam.BRASS)
	draw_circle(Vector2(2.5 + facing, -21.5 + bob), 2.4, Steam.BRASS)
	draw_circle(Vector2(-2.5 + facing, -21.5 + bob), 1.3, Steam.AETHER)
	draw_circle(Vector2(2.5 + facing, -21.5 + bob), 1.3, Steam.AETHER)
