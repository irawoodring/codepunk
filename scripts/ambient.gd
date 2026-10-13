extends Node2D
## Animated atmosphere drawn above the world: steam puffs from vents and
## flickering glow around lamp posts.

var vents: Array[Vector2] = []
var lamps: Array[Vector2] = []
var _time := 0.0


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	for i in lamps.size():
		var p := lamps[i] + Vector2(0, -12)
		var flicker := 0.85 + 0.15 * sin(_time * 7.0 + i * 1.7) * sin(_time * 3.1 + i)
		for ring in 4:
			draw_circle(p, 18.0 + ring * 14.0, Color(1.0, 0.8, 0.45, 0.06 * flicker))
	for i in vents.size():
		var base := vents[i]
		for k in 4:
			var phase := fmod(_time * 0.6 + k * 0.25 + i * 0.37, 1.0)
			var drift := sin((_time + k) * 1.3 + i) * 6.0 * phase
			var p := base + Vector2(drift, -phase * 44.0)
			var alpha := (1.0 - phase) * 0.35
			draw_circle(p, 5.0 + phase * 12.0, Color(0.92, 0.9, 0.86, alpha))
