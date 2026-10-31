class_name Game
extends Node2D
## Ion Drift main loop: spawn ions/debris, score scoops, track hits, drive HUD.

enum State { PLAYING, OVER }

@onready var world: Node2D = $World
@onready var player: PlayerCraft = $World/Player
@onready var ions_root: Node2D = $World/Ions
@onready var debris_root: Node2D = $World/Debris
@onready var fx_root: Node2D = $World/Fx
@onready var hud: GameHUD = $HUD
@onready var autopilot: AutoPilot = $AutoPilot

var state: State = State.PLAYING
var score: int = 0
var combo: int = 0
var hits: int = 0
var scooped: int = 0
var best_combo: int = 0
var since_scoop: float = 99.0
var spawn_ion_t: float = 0.0
var spawn_debris_t: float = 0.0
var play_time: float = 0.0
var _rng := RandomNumberGenerator.new()
var _seed: int = 11
var _over_at: float = 0.0


func _ready() -> void:
	_rng.seed = _seed
	player.use_ai = AutoPilot.is_requested()
	player.position = Vector2(Rules.PLAY_W * 0.5, Rules.PLAY_H * 0.5)
	player.hit.connect(_on_player_hit)
	hud.show_playing_hint(player.use_ai)
	hud.set_score(0)
	hud.set_combo(0)
	hud.set_lives(Rules.lives_left(0))
	_seed_start_field()
	if player.use_ai:
		print("IONDRIFT_AUTOPILOT seed=", _seed)


func _seed_start_field() -> void:
	for i in 8:
		_spawn_ion(_safe_point(180.0))
	for i in 5:
		_spawn_debris(_edge_point())


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart") and state == State.OVER:
		get_tree().reload_current_scene()
		return
	if OS.has_feature("movie"):
		var limit: float = 32.0
		if state == State.OVER:
			limit = play_time + 0.01  # allow current frame, then next check
		if play_time >= 32.0 or (state == State.OVER and play_time >= _over_at + 1.5):
			print("IONDRIFT_MOVIE_QUIT time=", snappedf(play_time, 0.01), " score=", score)
			get_tree().quit()
			return
	if state != State.PLAYING:
		return
	play_time += delta
	if int(play_time * 2) != int((play_time - delta) * 2):
		print("PERF fps=%d score=%d" % [Engine.get_frames_per_second(), score])
	since_scoop += delta
	if since_scoop > Rules.COMBO_WINDOW_S and combo > 0:
		combo = 0
		hud.set_combo(0)

	spawn_ion_t -= delta
	spawn_debris_t -= delta
	if spawn_ion_t <= 0.0:
		spawn_ion_t = _rng.randf_range(0.35, 0.75)
		if ions_root.get_child_count() < 14:
			_spawn_ion(_safe_point(90.0))
	if spawn_debris_t <= 0.0:
		spawn_debris_t = _rng.randf_range(1.4, 2.4)
		if debris_root.get_child_count() < 10:
			_spawn_debris(_edge_point())

	_check_scoops()
	_check_debris_hits()


func _check_scoops() -> void:
	var keep: Array[Node] = []
	for child in ions_root.get_children():
		var ion := child as IonPickup
		if ion == null or not ion.alive:
			continue
		if Rules.circles_overlap(player.position, player.radius(), ion.position, ion.radius):
			ion.alive = false
			_on_scoop(ion.position)
			ion.queue_free()
		else:
			keep.append(ion)


func _check_debris_hits() -> void:
	for child in debris_root.get_children():
		var rock := child as DebrisRock
		if rock == null or not rock.alive:
			continue
		if Rules.circles_overlap(player.position, player.radius() * 0.85, rock.position, rock.radius * 0.85):
			player.take_hit()


func _on_scoop(at: Vector2) -> void:
	combo = Rules.next_combo(combo, since_scoop)
	since_scoop = 0.0
	var pts: int = Rules.points_for_scoop(combo)
	score += pts
	scooped += 1
	best_combo = maxi(best_combo, combo)
	hud.set_score(score)
	hud.set_combo(combo)
	_burst(at, "scoop", 10.0)
	print("IONDRIFT_SCOOP score=", score, " combo=", combo, " scooped=", scooped)


func _on_player_hit() -> void:
	hits += 1
	hud.set_lives(Rules.lives_left(hits))
	_burst(player.position, "hit", 14.0)
	print("IONDRIFT_HIT hits=", hits, " lives=", Rules.lives_left(hits))
	combo = 0
	since_scoop = 99.0
	hud.set_combo(0)
	if Rules.is_dead(hits):
		_game_over()


func _game_over() -> void:
	state = State.OVER
	_over_at = play_time
	player.alive = false
	hud.show_game_over(score, scooped, best_combo)
	print("IONDRIFT_OVER score=", score, " scooped=", scooped, " best_combo=", best_combo, " time=", snappedf(play_time, 0.01))


func _burst(at: Vector2, kind: String, r: float) -> void:
	var b := ScoopBurst.new()
	b.position = at
	b.kind = kind
	b.base_r = r
	fx_root.add_child(b)


func _spawn_ion(pos: Vector2) -> void:
	var ion := IonPickup.new()
	ion.position = pos
	ions_root.add_child(ion)


func _spawn_debris(pos: Vector2) -> void:
	var rock := DebrisRock.new()
	rock.setup(_rng, pos)
	debris_root.add_child(rock)


func _safe_point(min_from_player: float) -> Vector2:
	for _i in 20:
		var p := Vector2(
			_rng.randf_range(Rules.MARGIN + 20.0, Rules.PLAY_W - Rules.MARGIN - 20.0),
			_rng.randf_range(Rules.MARGIN + 20.0, Rules.PLAY_H - Rules.MARGIN - 20.0)
		)
		if player == null or p.distance_to(player.position) >= min_from_player:
			return p
	return Vector2(Rules.PLAY_W * 0.25, Rules.PLAY_H * 0.25)


func _edge_point() -> Vector2:
	var side: int = _rng.randi_range(0, 3)
	match side:
		0:
			return Vector2(-30.0, _rng.randf_range(40.0, Rules.PLAY_H - 40.0))
		1:
			return Vector2(Rules.PLAY_W + 30.0, _rng.randf_range(40.0, Rules.PLAY_H - 40.0))
		2:
			return Vector2(_rng.randf_range(40.0, Rules.PLAY_W - 40.0), -30.0)
		_:
			return Vector2(_rng.randf_range(40.0, Rules.PLAY_W - 40.0), Rules.PLAY_H + 30.0)


func ions() -> Array[IonPickup]:
	var out: Array[IonPickup] = []
	for c in ions_root.get_children():
		if c is IonPickup and (c as IonPickup).alive:
			out.append(c)
	return out


func debris() -> Array[DebrisRock]:
	var out: Array[DebrisRock] = []
	for c in debris_root.get_children():
		if c is DebrisRock and (c as DebrisRock).alive:
			out.append(c)
	return out
