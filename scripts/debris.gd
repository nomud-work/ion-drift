class_name DebrisRock
extends Node2D
## Drifting rock. Shape is seeded so Movie Maker runs look stable.

var radius: float = 18.0
var velocity: Vector2 = Vector2.ZERO
var spin: float = 0.0
var angle: float = 0.0
var verts: PackedVector2Array = PackedVector2Array()
var alive: bool = true


func setup(rng: RandomNumberGenerator, pos: Vector2) -> void:
	position = pos
	radius = rng.randf_range(Rules.DEBRIS_MIN_R, Rules.DEBRIS_MAX_R)
	var spd: float = rng.randf_range(28.0, 70.0)
	var dir: float = rng.randf() * TAU
	velocity = Vector2(cos(dir), sin(dir)) * spd
	spin = rng.randf_range(-1.2, 1.2)
	verts = PackedVector2Array()
	var n: int = rng.randi_range(5, 7)
	for i in n:
		var a: float = TAU * float(i) / float(n) + rng.randf_range(-0.2, 0.2)
		var r: float = radius * rng.randf_range(0.65, 1.05)
		verts.append(Vector2(cos(a), sin(a)) * r)


func _process(delta: float) -> void:
	if not alive:
		return
	position += velocity * delta
	angle += spin * delta
	# wrap softly
	if position.x < -40.0:
		position.x = Rules.PLAY_W + 40.0
	elif position.x > Rules.PLAY_W + 40.0:
		position.x = -40.0
	if position.y < -40.0:
		position.y = Rules.PLAY_H + 40.0
	elif position.y > Rules.PLAY_H + 40.0:
		position.y = -40.0
	queue_redraw()


func _draw() -> void:
	if not alive or verts.is_empty():
		return
	var xf := Transform2D(angle, Vector2.ZERO)
	var pts := PackedVector2Array()
	for v in verts:
		pts.append(xf * v)
	draw_colored_polygon(pts, Color(0.35, 0.28, 0.32, 0.95))
	draw_polyline(pts + PackedVector2Array([pts[0]]), Color(0.7, 0.55, 0.5, 0.85), 1.5, true)
	# crater dots
	draw_circle(xf * Vector2(radius * 0.2, -radius * 0.15), radius * 0.18, Color(0.22, 0.18, 0.2, 0.8))
