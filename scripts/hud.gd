class_name GameHUD
extends CanvasLayer
## ASCII-only HUD so web glyphs do not fall back to boxes.

@onready var score_label: Label = $Root/Score
@onready var combo_label: Label = $Root/Combo
@onready var lives_label: Label = $Root/Lives
@onready var hint_label: Label = $Root/Hint
@onready var over_label: Label = $Root/Over


func _ready() -> void:
	over_label.visible = false


func set_score(v: int) -> void:
	score_label.text = "SCORE  %d" % v


func set_combo(c: int) -> void:
	if c <= 1:
		combo_label.text = ""
	else:
		combo_label.text = "COMBO x%d" % c


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
	hint_label.text = ""
