class_name IonPickup
extends Node2D
## Glowing ion scoop target.

var radius: float = Rules.ION_RADIUS
var age: float = 0.0
var pulse: float = 0.0
var alive: bool = true


func _process(delta: float) -> void:
	if not alive:
		return
	age += delta
	pulse += delta * 4.0
	queue_redraw()


func _draw() -> void:
	if not alive:
		return
	var s: float = 1.0 + 0.15 * sin(pulse)
	draw_circle(Vector2.ZERO, radius * 2.2 * s, Color(0.2, 1.0, 0.7, 0.12))
	draw_circle(Vector2.ZERO, radius * 1.4 * s, Color(0.35, 1.0, 0.8, 0.28))
	draw_circle(Vector2.ZERO, radius * s, Color(0.55, 1.0, 0.9, 0.95))
	draw_circle(Vector2.ZERO, radius * 0.35, Color(1.0, 1.0, 1.0, 0.95))
