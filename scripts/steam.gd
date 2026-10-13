class_name Steam
extends RefCounted
## Steampunk palette, UI theme and small drawing helpers shared by the game.
## Everything is drawn in code, so the project needs no image assets.

const BRASS := Color("c8a050")
const BRASS_LIGHT := Color("f0d080")
const BRASS_DARK := Color("7a5a28")
const COPPER := Color("b87333")
const IRON := Color("3a3a40")
const WOOD := Color("2b1d14")
const WOOD_MID := Color("3d2a1c")
const WOOD_LIGHT := Color("5a3e28")
const PARCHMENT := Color("f0e0c0")
const PARCHMENT_DIM := Color("b8a888")
const INK := Color("1a120c")
const VERDIGRIS := Color("5fc8a0")
const RUST := Color("e0603f")
const AETHER := Color("7ae0f0")
const CODE_BG := Color("17110c")

const TIER_COLORS := {"CS1": COPPER, "CS2": AETHER}


## Fonts are bundled (see fonts/, SIL Open Font License) because a web
## browser doesn't let the game use the computer's installed fonts.
static func serif_font(weight: int = 400, italic: bool = false) -> Font:
	var path := "res://fonts/LibreBaskerville-Italic.ttf" if italic else "res://fonts/LibreBaskerville.ttf"
	return _weighted(load(path), weight)


static func mono_font(weight: int = 400) -> Font:
	var f := _weighted(load("res://fonts/JetBrainsMono.ttf"), weight)
	# No ligatures: beginners should see ">=" and "!=" exactly as they type them.
	var ts := TextServerManager.get_primary_interface()
	f.opentype_features = {ts.name_to_tag("calt"): 0, ts.name_to_tag("liga"): 0}
	return f


static func _weighted(base: Font, weight: int) -> FontVariation:
	var v := FontVariation.new()
	v.base_font = base
	v.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): weight}
	return v


static func box(bg: Color = WOOD, border: Color = BRASS, width: int = 3, radius: int = 6,
		margin: int = 12) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(width)
	s.set_corner_radius_all(radius)
	s.set_content_margin_all(margin)
	s.shadow_color = Color(0, 0, 0, 0.45)
	s.shadow_size = 6
	return s


static func make_theme() -> Theme:
	var t := Theme.new()
	t.default_font = serif_font()
	t.default_font_size = 18

	t.set_stylebox("panel", "Panel", box())
	t.set_stylebox("panel", "PanelContainer", box())

	var normal := box(WOOD_LIGHT, BRASS_DARK, 2, 5, 8)
	var hover := box(Color("6e4c30"), BRASS, 2, 5, 8)
	var pressed := box(BRASS_DARK, BRASS_LIGHT, 2, 5, 8)
	var disabled := box(WOOD_MID, Color("4a3a2a"), 2, 5, 8)
	for s in [normal, hover, pressed, disabled]:
		s.shadow_size = 2
		s.content_margin_left = 14
		s.content_margin_right = 14
	t.set_stylebox("normal", "Button", normal)
	t.set_stylebox("hover", "Button", hover)
	t.set_stylebox("pressed", "Button", pressed)
	t.set_stylebox("disabled", "Button", disabled)
	t.set_stylebox("focus", "Button", box(Color(0, 0, 0, 0), BRASS_LIGHT, 2, 5, 8))
	t.set_color("font_color", "Button", PARCHMENT)
	t.set_color("font_hover_color", "Button", BRASS_LIGHT)
	t.set_color("font_pressed_color", "Button", INK)
	t.set_color("font_disabled_color", "Button", Color("7a6a58"))

	t.set_color("font_color", "Label", PARCHMENT)
	t.set_color("default_color", "RichTextLabel", PARCHMENT)
	var mono := mono_font()
	t.set_font("mono_font", "RichTextLabel", mono)
	t.set_font("bold_font", "RichTextLabel", serif_font(700))
	t.set_font("italics_font", "RichTextLabel", serif_font(400, true))
	t.set_font("bold_italics_font", "RichTextLabel", serif_font(700, true))

	var field := box(CODE_BG, BRASS_DARK, 2, 4, 8)
	field.shadow_size = 0
	t.set_stylebox("normal", "LineEdit", field)
	t.set_stylebox("focus", "LineEdit", box(CODE_BG, BRASS, 2, 4, 8))
	t.set_color("font_color", "LineEdit", PARCHMENT)
	t.set_font("font", "LineEdit", mono)

	var code := box(CODE_BG, BRASS_DARK, 2, 4, 6)
	code.shadow_size = 0
	t.set_stylebox("normal", "CodeEdit", code)
	t.set_stylebox("focus", "CodeEdit", box(CODE_BG, BRASS, 2, 4, 6))
	t.set_font("font", "CodeEdit", mono)
	t.set_font_size("font_size", "CodeEdit", 17)
	t.set_color("font_color", "CodeEdit", Color("e8dcc4"))
	t.set_color("caret_color", "CodeEdit", BRASS_LIGHT)
	t.set_color("selection_color", "CodeEdit", Color(0.78, 0.63, 0.31, 0.35))
	t.set_color("current_line_color", "CodeEdit", Color(1, 1, 1, 0.04))
	t.set_color("line_number_color", "CodeEdit", Color("7a6a58"))
	t.set_color("background_color", "CodeEdit", CODE_BG)

	t.set_stylebox("panel", "TooltipPanel", box(WOOD, BRASS, 1, 4, 6))
	t.set_color("font_color", "TooltipLabel", PARCHMENT)
	return t


## Python syntax highlighting with a brass-and-ink colour scheme.
static func python_highlighter() -> CodeHighlighter:
	var h := CodeHighlighter.new()
	h.number_color = Color("e0a070")
	h.symbol_color = Color("c8b090")
	h.function_color = Color("f0d080")
	h.member_variable_color = Color("e8dcc4")
	var keyword := Color("e0805a")
	for k in ["def", "class", "return", "if", "elif", "else", "for", "while", "in", "not",
			"and", "or", "is", "import", "from", "as", "pass", "break", "continue", "try",
			"except", "finally", "raise", "with", "lambda", "yield", "global", "nonlocal",
			"del", "assert"]:
		h.add_keyword_color(k, keyword)
	var constant := Color("9ad0e0")
	for k in ["True", "False", "None", "self"]:
		h.add_keyword_color(k, constant)
	var builtin := Color("8fd0a8")
	for k in ["print", "len", "range", "int", "str", "float", "list", "dict", "set", "tuple",
			"sorted", "sum", "min", "max", "abs", "round", "enumerate", "zip", "isinstance",
			"type", "super", "ValueError", "RuntimeError", "TypeError", "KeyError", "IndexError"]:
		h.add_keyword_color(k, builtin)
	var string := Color("b8d080")
	h.add_color_region('"""', '"""', string)
	h.add_color_region("'''", "'''", string)
	h.add_color_region('"', '"', string)
	h.add_color_region("'", "'", string)
	h.add_color_region("#", "", Color("8a7a68"), true)
	return h


## Give every RichTextLabel font style the same size (otherwise bold and
## italic text falls back to the theme default and looks too big).
static func set_rich_text_size(label: RichTextLabel, size: int, mono_size: int = -1) -> void:
	for key in ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size"]:
		label.add_theme_font_size_override(key, size)
	label.add_theme_font_size_override("mono_font_size", mono_size if mono_size > 0 else size - 2)


# --- Drawing helpers ---

static func gear_points(center: Vector2, radius: float, teeth: int, depth: float,
		rot: float = 0.0) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var steps := teeth * 4
	for i in steps:
		var a := rot + TAU * float(i) / float(steps)
		var r := radius if (i % 4) < 2 else radius - depth
		pts.append(center + Vector2(cos(a), sin(a)) * r)
	return pts


static func draw_gear(ci: CanvasItem, center: Vector2, radius: float, teeth: int,
		color: Color, rot: float = 0.0, hole: Color = Color(0, 0, 0, 0.55)) -> void:
	var depth: float = max(2.0, radius * 0.22)
	ci.draw_colored_polygon(gear_points(center, radius, teeth, depth, rot), color)
	ci.draw_circle(center, radius - depth - 1.0, color.lightened(0.12))
	ci.draw_circle(center, radius * 0.32, hole)


static func ellipse(center: Vector2, rx: float, ry: float, segments: int = 18) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in segments:
		var a := TAU * float(i) / float(segments)
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	return pts
