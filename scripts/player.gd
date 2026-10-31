class_name PlayerCraft
extends Node2D
## Tiny scoop craft. Input or AI drive velocity; game checks collisions.

signal scooped
signal hit

var velocity: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.RIGHT
var boosting: bool = false
var boost_left: float = 0.0
var boost_cd: float = 0.0
var invuln: float = 0.0
var alive: bool = true
var ai_dir: Vector2 = Vector2.ZERO
var ai_boost: bool = false
var use_ai: bool = false
var trail: Array[Vector2] = []


func _physics_process(delta: float) -> void:
	if not alive:
		return
	if invuln > 0.0:
		invuln = maxf(0.0, invuln - delta)
	if boost_cd > 0.0:
		boost_cd = maxf(0.0, boost_cd - delta)
	if boost_left > 0.0:
		boost_left = maxf(0.0, boost_left - delta)
		boosting = boost_left > 0.0
	else:
		boosting = false

	var dir := Vector2.ZERO
	var want_boost := false
	if use_ai:
		dir = ai_dir
		want_boost = ai_boost
	else:
		dir.x = Input.get_axis("move_left", "move_right")
		dir.y = Input.get_axis("move_up", "move_down")
		want_boost = Input.is_action_just_pressed("boost")

	if dir.length_squared() > 1.0:
		dir = dir.normalized()
	if dir.length_squared() > 0.01:
		facing = dir.normalized()

	if want_boost and boost_cd <= 0.0 and boost_left <= 0.0:
		boost_left = Rules.BOOST_DURATION_S
		boost_cd = Rules.BOOST_COOLDOWN_S
		boosting = true

	var spd: float = Rules.PLAYER_SPEED * (Rules.BOOST_MULT if boosting else 1.0)
	velocity = dir * spd
	position = Rules.clamp_pos(position + velocity * delta)

	trail.push_front(position)
	if trail.size() > 14:
		trail.resize(14)
	queue_redraw()


func take_hit() -> void:
	if invuln > 0.0 or not alive:
		return
	invuln = Rules.HIT_INVULN_S
	hit.emit()


func radius() -> float:
	return Rules.PLAYER_RADIUS


func _draw() -> void:
	# trail
	for i in trail.size():
		var a: float = 0.25 * (1.0 - float(i) / float(maxi(1, trail.size())))
		var c := Color(0.3, 0.85, 1.0, a) if boosting else Color(0.35, 0.55, 0.9, a * 0.7)
		draw_circle(to_local(trail[i]), 3.0 - i * 0.12, c)

	var flicker: bool = invuln > 0.0 and int(invuln * 12.0) % 2 == 0
	if flicker:
		return

	var tip := facing * 16.0
	var left := facing.rotated(2.4) * 11.0
	var right := facing.rotated(-2.4) * 11.0
	var hull := PackedVector2Array([tip, left, right])
	var col := Color(0.35, 0.95, 1.0) if boosting else Color(0.55, 0.85, 1.0)
	draw_colored_polygon(hull, col)
	draw_polyline(PackedVector2Array([tip, left, right, tip]), Color(0.9, 1.0, 1.0, 0.9), 1.5, true)
	# scoop glow at nose
	draw_circle(tip * 0.55, 3.5, Color(0.5, 1.0, 0.85, 0.85))
	if boosting:
		draw_circle(-facing * 10.0, 5.0, Color(1.0, 0.55, 0.2, 0.7))
