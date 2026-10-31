class_name GameHUD
extends CanvasLayer
## ASCII-only HUD so web glyphs do not fall back to boxes.
## Unified opaque Panel cards prevent Movie Maker dirty-rect trails
## without per-label staircase boxes.

@onready var score_panel: Panel = $Root/ScorePanel
@onready var score_label: Label = $Root/ScorePanel/Score
@onready var combo_label: Label = $Root/ScorePanel/Combo
@onready var hull_panel: Panel = $Root/HullPanel
@onready var lives_label: Label = $Root/HullPanel/Lives
@onready var hint_panel: Panel = $Root/HintPanel
@onready var hint_label: Label = $Root/HintPanel/Hint
@onready var over_label: Label = $Root/Over

const CLEAR := Color(0.02, 0.03, 0.06, 1.0)
const BORDER := Color(0.10, 0.16, 0.26, 1.0)
const COMBO_BLANK := "            "  # same width as "COMBO x12 "


func _ready() -> void:
	_apply_unified_panels()
	over_label.visible = false


func _make_card_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = CLEAR
	sb.border_color = BORDER
	sb.set_border_width_all(1)
	sb.content_margin_left = 10.0
	sb.content_margin_right = 10.0
	sb.content_margin_top = 4.0
	sb.content_margin_bottom = 4.0
	sb.corner_radius_top_left = 2
	sb.corner_radius_top_right = 2
	sb.corner_radius_bottom_left = 2
	sb.corner_radius_bottom_right = 2
	return sb


func _apply_unified_panels() -> void:
	# One opaque card per region; labels stay transparent so edges align.
	var card := _make_card_style()
	for panel in [score_panel, hull_panel, hint_panel]:
		panel.add_theme_stylebox_override("panel", card)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for lab in [score_label, combo_label, lives_label, hint_label]:
		lab.remove_theme_stylebox_override("normal")
		lab.clip_text = false
		lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Game-over stays a single opaque StyleBoxFlat card (centered).
	var sb := _make_card_style()
	sb.content_margin_left = 16.0
	sb.content_margin_right = 16.0
	sb.content_margin_top = 12.0
	sb.content_margin_bottom = 12.0
	over_label.add_theme_stylebox_override("normal", sb)
	over_label.clip_text = false


func set_score(v: int) -> void:
	# Fixed-width padding so digit growth does not leave trails.
	score_label.text = "SCORE  %-6d" % v


func set_combo(c: int) -> void:
	# Always paint a fixed-width string (spaces when idle) so the panel
	# content stays stable and Movie Maker never stacks digit remnants.
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
