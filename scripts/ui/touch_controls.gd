extends Control
## On-screen controls for phones and tablets: touch anywhere on the left half
## of the screen to get a joystick, and use the buttons on the right to
## interact, open the satchel or open the menu. Multi-touch, so you can walk
## and press USE at the same time.

const STICK_RADIUS := 60.0
const DEADZONE := 0.2
const DIRECTIONS := {"move_left": Vector2.LEFT, "move_right": Vector2.RIGHT,
	"move_up": Vector2.UP, "move_down": Vector2.DOWN}

var _touch := -1
var _center := Vector2.ZERO
var _knob := Vector2.ZERO
var _use: ActionButton
var _bag: ActionButton
var _menu: ActionButton


class ActionButton:
	extends TouchScreenButton
	var label := ""
	var radius := 40.0

	func _init(p_label: String, p_action: String, p_radius: float) -> void:
		label = p_label
		action = p_action
		radius = p_radius
		var circle := CircleShape2D.new()
		circle.radius = p_radius
		shape = circle
		shape_centered = true
		shape_visible = false
		pressed.connect(queue_redraw)
		released.connect(queue_redraw)

	func _draw() -> void:
		var down := is_pressed()
		draw_circle(Vector2.ZERO, radius, Color(0.17, 0.11, 0.08, 0.8 if down else 0.6))
		draw_arc(Vector2.ZERO, radius - 1.5, 0, TAU, 40,
			Steam.BRASS_LIGHT if down else Steam.BRASS, 3.0, true)
		var font := Steam.serif_font(700)
		var size := int(radius * 0.42)
		var width := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		draw_string(font, Vector2(-width / 2.0, size * 0.35), label, HORIZONTAL_ALIGNMENT_LEFT,
			-1, size, Steam.BRASS_LIGHT if down else Steam.PARCHMENT)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_use = ActionButton.new("USE", "interact", 46)
	_bag = ActionButton.new("BAG", "satchel", 32)
	_menu = ActionButton.new("MENU", "menu", 28)
	for b in [_use, _bag, _menu]:
		add_child(b)
	resized.connect(_place_buttons)
	visibility_changed.connect(_release)
	_place_buttons()


func _place_buttons() -> void:
	_use.position = Vector2(size.x - 78, size.y - 84)
	_bag.position = Vector2(size.x - 168, size.y - 52)
	_menu.position = Vector2(size.x - 44, 44)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event is InputEventScreenTouch:
		if event.pressed and _touch == -1 and _in_stick_zone(event.position):
			_touch = event.index
			_center = event.position
			_move_knob(event.position)
		elif not event.pressed and event.index == _touch:
			_release()
	elif event is InputEventScreenDrag and event.index == _touch:
		_move_knob(event.position)


func _in_stick_zone(p: Vector2) -> bool:
	return p.x < size.x * 0.5 and p.y > 90.0 and not GameState.is_modal_open()


func _move_knob(p: Vector2) -> void:
	_knob = (p - _center).limit_length(STICK_RADIUS)
	var v := _knob / STICK_RADIUS
	if v.length() < DEADZONE:
		v = Vector2.ZERO
	for action in DIRECTIONS:
		var strength: float = maxf(0.0, v.dot(DIRECTIONS[action]))
		if strength > 0.0:
			Input.action_press(action, strength)
		else:
			Input.action_release(action)
	queue_redraw()


func _release() -> void:
	_touch = -1
	_knob = Vector2.ZERO
	for action in DIRECTIONS:
		Input.action_release(action)
	queue_redraw()


func _draw() -> void:
	# A faint resting joystick shows where to touch; it follows your thumb.
	var base := _center if _touch != -1 else Vector2(110, size.y - 110)
	var alpha := 0.55 if _touch != -1 else 0.25
	draw_circle(base, STICK_RADIUS, Color(0.17, 0.11, 0.08, alpha))
	draw_arc(base, STICK_RADIUS, 0, TAU, 48, Color(Steam.BRASS, alpha + 0.2), 2.5, true)
	Steam.draw_gear(self, base + _knob, 22, 10, Color(Steam.BRASS, alpha + 0.35))
