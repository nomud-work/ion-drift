class_name GameHUD
extends CanvasLayer
## ASCII-only HUD so web glyphs do not fall back to boxes.
## Opaque Label StyleBoxFlat backgrounds prevent Movie Maker dirty-rect trails.

@onready var score_label: Label = $Root/Score
@onready var combo_label: Label = $Root/Combo
@onready var lives_label: Label = $Root/Lives
@onready var hint_label: Label = $Root/Hint
@onready var over_label: Label = $Root/Over

const CLEAR := Color(0.02, 0.03, 0.06, 1.0)
const COMBO_BLANK := "            "  # same width as "COMBO x12 "


func _ready() -> void:
	_apply_opaque_panels()
	over_label.visible = false


func _apply_opaque_panels() -> void:
	for lab in [score_label, combo_label, lives_label, hint_label, over_label]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = CLEAR
		sb.content_margin_left = 6.0
		sb.content_margin_right = 6.0
		sb.content_margin_top = 2.0
		sb.content_margin_bottom = 2.0
		lab.add_theme_stylebox_override("normal", sb)
		# Keep a stable draw rect so Movie Maker dirty rects fully clear.
		lab.clip_text = false


func set_score(v: int) -> void:
	# Fixed-ish width padding so digit growth does not leave trails.
	score_label.text = "SCORE  %-6d" % v


func set_combo(c: int) -> void:
	# Always paint a fixed-width string (spaces when idle) so the StyleBox
	# rect stays constant and Movie Maker never stacks digit remnants.
	if c <= 1:
		combo_label.text = COMBO_BLANK
	else:
		combo_label.text = "COMBO x%-2d  " % c


func set_lives(n: int) -> void:
	var marks := ""
	for i in Rules.MAX_HITS:
		marks += ("+" if i < n else "-")
		if i < Rules.MAX_HITS - 1:
			marks += " "
	lives_label.text = "HULL  " + marks


func show_playing_hint(autopilot: bool) -> void:
	if autopilot:
		hint_label.text = "AUTOPILOT  WASD move  Space boost"
	else:
		hint_label.text = "WASD / arrows move   Space boost   R restart"
	over_label.visible = false


func show_game_over(score: int, scooped: int, best_combo: int) -> void:
	over_label.visible = true
	over_label.text = "DRIFT ENDED\nscore %d   ions %d   best combo x%d\npress R to restart" % [score, scooped, best_combo]
	hint_label.text = "                                        "
