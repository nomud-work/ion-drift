extends SceneTree
## Headless asserts for Ion Drift rules. Exit 0 on pass.

func _init() -> void:
	var failed := 0
	var passed := 0

	failed += _check("points_combo1", Rules.points_for_scoop(1) == 100)
	failed += _check("points_combo3", Rules.points_for_scoop(3) == 300)
	failed += _check("points_cap", Rules.points_for_scoop(99) == 100 * Rules.MAX_COMBO)
	failed += _check("next_combo_fresh", Rules.next_combo(0, 99.0) == 1)
	failed += _check("next_combo_chain", Rules.next_combo(2, 0.5) == 3)
	failed += _check("next_combo_break", Rules.next_combo(5, Rules.COMBO_WINDOW_S + 0.1) == 1)
	failed += _check("next_combo_cap", Rules.next_combo(Rules.MAX_COMBO, 0.1) == Rules.MAX_COMBO)
	failed += _check("dead_false", Rules.is_dead(2) == false)
	failed += _check("dead_true", Rules.is_dead(3) == true)
	failed += _check("lives", Rules.lives_left(1) == 2)
	failed += _check("clamp_inside", Rules.clamp_pos(Vector2(100, 100)) == Vector2(100, 100))
	failed += _check("clamp_edge", Rules.clamp_pos(Vector2(-10, 999)).x == Rules.MARGIN)
	failed += _check("overlap_yes", Rules.circles_overlap(Vector2.ZERO, 10.0, Vector2(15, 0), 10.0))
	failed += _check("overlap_no", not Rules.circles_overlap(Vector2.ZERO, 5.0, Vector2(40, 0), 5.0))

	passed = 14 - failed
	print("IONDRIFT_TESTS passed=", passed, " failed=", failed, " total=14")
	quit(0 if failed == 0 else 1)


func _check(name: String, ok: bool) -> int:
	if ok:
		print("PASS ", name)
		return 0
	print("FAIL ", name)
	return 1
