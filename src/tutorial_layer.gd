extends CanvasLayer


# =========================================================
# VARIABLES
# =========================================================

var tutorial_active: bool = false
var tutorial_finished: bool = false


# =========================================================
# NODES
# =========================================================

@onready var tutorial_ui: Control = $TutorialUI


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	# Hide tutorial at first
	visible = false

	# Make tutorial transparent
	tutorial_ui.modulate.a = 0.0


	# Get current level
	var current_level := get_tree().current_scene.scene_file_path

	print("================================")
	print("TUTORIAL CHECK")
	print("CURRENT LEVEL: ", current_level)
	print("================================")


	# Check if tutorial was already shown
	if GameManager.tutorial_seen_levels.has(current_level):

		print("TUTORIAL ALREADY SHOWN: ", current_level)

		return


	# Remember that this level has shown tutorial
	GameManager.tutorial_seen_levels[current_level] = true


	# Show tutorial
	call_deferred("show_tutorial")


# =========================================================
# SHOW TUTORIAL
# =========================================================

func show_tutorial() -> void:

	tutorial_active = true

	# IMPORTANT:
	# Make the CanvasLayer visible
	visible = true

	# Start transparent
	tutorial_ui.modulate.a = 0.0


	# =====================================================
	# FREEZE PLAYER
	# =====================================================

	var player = get_tree().get_first_node_in_group("player")

	if player:

		player.tutorial_active = true
		player.velocity = Vector2.ZERO

		print("PLAYER FROZEN FOR TUTORIAL")

	else:

		print("WARNING: PLAYER NOT FOUND!")


	# =====================================================
	# FADE IN
	# =====================================================

	var fade_in := create_tween()

	fade_in.tween_property(
		tutorial_ui,
		"modulate:a",
		1.0,
		0.8
	)

	await fade_in.finished

	print("================================")
	print("TUTORIAL APPEARED")
	print("================================")


# =========================================================
# INPUT
# =========================================================

func _input(event: InputEvent) -> void:

	if not tutorial_active:
		return


	# Click anywhere to continue
	if event is InputEventMouseButton:

		if event.pressed:

			close_tutorial()


# =========================================================
# CLOSE TUTORIAL
# =========================================================

func close_tutorial() -> void:

	if not tutorial_active:
		return


	tutorial_active = false
	tutorial_finished = true

	print("TUTORIAL FINISHED!")


	# =====================================================
	# FADE OUT
	# =====================================================

	var fade_out := create_tween()

	fade_out.tween_property(
		tutorial_ui,
		"modulate:a",
		0.0,
		0.5
	)

	await fade_out.finished

	visible = false

	print("TUTORIAL CLOSED!")


	# =====================================================
	# LOCATION INTRO
	# =====================================================

	var location_intro = get_tree().get_first_node_in_group(
		"location_intro"
	)

	if location_intro:

		await location_intro.show_location()

	else:

		print("ERROR: LocationIntro NOT FOUND!")


	# =====================================================
	# SHOW QUEST
	# =====================================================

	var quest_ui = get_tree().get_first_node_in_group(
		"quest_ui"
	)

	if quest_ui:

		await quest_ui.show_quest()

	else:

		print("ERROR: QuestUI NOT FOUND!")


	# =====================================================
	# START GAMEPLAY
	# =====================================================

	var player = get_tree().get_first_node_in_group("player")

	if player:

		player.tutorial_active = false
		player.velocity = Vector2.ZERO

		print("PLAYER UNFROZEN")


	print("================================")
	print("GAMEPLAY STARTED!")
	print("================================")
