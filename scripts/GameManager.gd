extends Node

# =========================
# PLAYER UPGRADES
# =========================

var has_double_jump: bool = false
var has_triple_shot: bool = false

var tutorial_seen_levels: Dictionary = {}
# =========================
# RESET PLAYER PROGRESS
# =========================

func reset_progress() -> void:
	has_double_jump = false
	has_triple_shot = false

	print("================================")
	print("PLAYER UPGRADES RESET!")
	print("DOUBLE JUMP: ", has_double_jump)
	print("TRIPLE SHOT: ", has_triple_shot)
	print("================================")
