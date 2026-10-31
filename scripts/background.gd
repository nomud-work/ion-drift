class_name StarField
extends Node2D
## Soft drifting star field, code-drawn.

var _stars: Array[Dictionary] = []
var _t: float = 0.0


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in 90:
		_stars.append({
			"p": Vector2(rng.randf() * Rules.PLAY_W, rng.randf() * Rules.PLAY_H),
			"s": rng.randf_range(0.6, 2.2),
			"a": rng.randf_range(0.15, 0.55),
			"v": Vector2(rng.randf_range(-8.0, -2.0), rng.randf_range(-3.0, 3.0)),
		})


func _process(delta: float) -> void:
	_t += delta
	for s in _stars:
		s["p"] = s["p"] + s["v"] * delta
		if s["p"].x < -4.0:
			s["p"].x = Rules.PLAY_W + 4.0
			s["p"].y = fposmod(s["p"].y, Rules.PLAY_H)
	queue_redraw()


func _draw() -> void:
	# nebula wash
	draw_rect(Rect2(0, 0, Rules.PLAY_W, Rules.PLAY_H), Color(0.02, 0.03, 0.06, 1.0))
	draw_circle(Vector2(180, 120), 160.0, Color(0.08, 0.12, 0.28, 0.35))
	draw_circle(Vector2(780, 420), 200.0, Color(0.12, 0.05, 0.22, 0.28))
	for s in _stars:
		var twinkle: float = 0.7 + 0.3 * sin(_t * 3.0 + s["p"].x * 0.01)
		draw_circle(s["p"], s["s"], Color(0.75, 0.85, 1.0, s["a"] * twinkle))
