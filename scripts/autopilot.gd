class_name AutoPilot
extends Node
## Seeded scoop autopilot for Movie Maker and web smoke. Off unless requested.

@export var game_path: NodePath = ^"../"
@export var player_path: NodePath = ^"../World/Player"

var game: Game
var player: PlayerCraft
var active: bool = false
var _rng := RandomNumberGenerator.new()
var _boost_cd: float = 0.0
var _wobble: float = 0.0


func _ready() -> void:
	active = is_requested()
	_rng.seed = 19
	game = get_node(game_path) as Game
	player = get_node(player_path) as PlayerCraft
	if active and player:
		player.use_ai = true


static func is_requested() -> bool:
	var args := OS.get_cmdline_user_args()
	if args.has("--autopilot") or args.has("autopilot=1"):
		return true
	for a in args:
		if a.begins_with("autopilot"):
			return true
	if OS.has_feature("web"):
		var q: Variant = JavaScriptBridge.eval("window.location.search", true)
		return q is String and (q as String).contains("autopilot")
	return false


func _physics_process(delta: float) -> void:
	if not active or game == null or player == null:
		return
	if game.state != Game.State.PLAYING or not player.alive:
		player.ai_dir = Vector2.ZERO
		player.ai_boost = false
		return

	_boost_cd = maxf(0.0, _boost_cd - delta)
	_wobble += delta
	var target := _pick_target()
	var avoid := _avoid_vector()
	var desire := Vector2.ZERO
	if target != Vector2.INF:
		desire = (target - player.position).normalized()
	desire = (desire * 1.0 + avoid * 1.55).normalized()
	# slight human-ish wobble so the path is readable on video
	desire = desire.rotated(sin(_wobble * 2.2) * 0.08)
	player.ai_dir = desire

	var danger_near := avoid.length() > 0.55
	var ion_aligned := false
	if target != Vector2.INF:
		var to_ion := target - player.position
		ion_aligned = to_ion.length() > 70.0 and desire.dot(to_ion.normalized()) > 0.82
	player.ai_boost = false
	if _boost_cd <= 0.0 and (danger_near or ion_aligned):
		player.ai_boost = true
		_boost_cd = 0.9


func _pick_target() -> Vector2:
	var best := Vector2.INF
	var best_score := -INF
	for ion in game.ions():
		var d: float = player.position.distance_to(ion.position)
		# prefer nearer ions, lightly penalize ones behind debris clusters
		var s: float = 400.0 - d
		for rock in game.debris():
			var mid: float = player.position.distance_to(rock.position)
			if mid < d and _segment_near(player.position, ion.position, rock.position, rock.radius + 20.0):
				s -= 80.0
		if s > best_score:
			best_score = s
			best = ion.position
	return best


func _avoid_vector() -> Vector2:
	var push := Vector2.ZERO
	for rock in game.debris():
		var delta: Vector2 = player.position - rock.position
		var dist: float = delta.length()
		var danger: float = rock.radius + Rules.PLAYER_RADIUS + 36.0
		if dist < danger and dist > 0.01:
			push += delta.normalized() * ((danger - dist) / danger)
	# soft wall push
	var m: float = Rules.MARGIN + 40.0
	if player.position.x < m:
		push.x += (m - player.position.x) / m
	if player.position.x > Rules.PLAY_W - m:
		push.x -= (player.position.x - (Rules.PLAY_W - m)) / m
	if player.position.y < m:
		push.y += (m - player.position.y) / m
	if player.position.y > Rules.PLAY_H - m:
		push.y -= (player.position.y - (Rules.PLAY_H - m)) / m
	if push.length_squared() > 1.0:
		push = push.normalized()
	return push


func _segment_near(a: Vector2, b: Vector2, p: Vector2, r: float) -> bool:
	var ab: Vector2 = b - a
	var t: float = clampf(ab.dot(p - a) / maxf(ab.length_squared(), 0.001), 0.0, 1.0)
	return a.lerp(b, t).distance_to(p) < r
