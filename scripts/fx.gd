class_name ScoopBurst
extends Node2D
## Short-lived scoop / hit flash.

var life: float = 0.35
var age: float = 0.0
var kind: String = "scoop"  # or "hit"
var base_r: float = 10.0


func _process(delta: float) -> void:
	age += delta
	if age >= life:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t: float = age / life
	var a: float = 1.0 - t
	if kind == "scoop":
		draw_circle(Vector2.ZERO, base_r + t * 28.0, Color(0.4, 1.0, 0.85, 0.35 * a))
		draw_circle(Vector2.ZERO, base_r * (1.0 - t * 0.5), Color(1.0, 1.0, 1.0, 0.7 * a))
	else:
		draw_circle(Vector2.ZERO, base_r + t * 36.0, Color(1.0, 0.35, 0.25, 0.4 * a))
		draw_circle(Vector2.ZERO, base_r * 0.6, Color(1.0, 0.8, 0.4, 0.5 * a))
