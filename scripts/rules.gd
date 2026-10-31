class_name Rules
extends RefCounted
## Pure Ion Drift rules — no nodes, so headless asserts can call them.

const MAX_HITS: int = 3
const MAX_COMBO: int = 12
const ION_BASE: int = 100
const COMBO_WINDOW_S: float = 2.4
const PLAYER_SPEED: float = 220.0
const BOOST_MULT: float = 2.1
const BOOST_DURATION_S: float = 0.28
const BOOST_COOLDOWN_S: float = 1.1
const PLAYER_RADIUS: float = 12.0
const ION_RADIUS: float = 8.0
const DEBRIS_MIN_R: float = 14.0
const DEBRIS_MAX_R: float = 28.0
const HIT_INVULN_S: float = 1.0
const PLAY_W: float = 960.0
const PLAY_H: float = 540.0
const MARGIN: float = 28.0


static func points_for_scoop(combo: int) -> int:
	return ION_BASE * clampi(combo, 1, MAX_COMBO)


static func next_combo(current: int, elapsed_since_scoop: float) -> int:
	if elapsed_since_scoop > COMBO_WINDOW_S:
		return 1
	return mini(current + 1, MAX_COMBO)


static func is_dead(hits: int) -> bool:
	return hits >= MAX_HITS


static func lives_left(hits: int) -> int:
	return maxi(0, MAX_HITS - hits)


static func clamp_pos(p: Vector2) -> Vector2:
	return Vector2(
		clampf(p.x, MARGIN, PLAY_W - MARGIN),
		clampf(p.y, MARGIN, PLAY_H - MARGIN)
	)


static func circles_overlap(a: Vector2, ar: float, b: Vector2, br: float) -> bool:
	var r: float = ar + br
	return a.distance_squared_to(b) <= r * r
