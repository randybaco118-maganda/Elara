extends CanvasLayer

var tutorial_active: bool = false
var tutorial_finished: bool = false

@onready var tutorial_ui: Control = $TutorialUI


func _ready() -> void:
	visible = false

	var current_level := get_tree().current_scene.scene_file_path

	# Check if this level already showed its tutorial
	if GameManager.tutorial_seen_levels.has(current_level):
		print("TUTORIAL ALREADY SHOWN: ", current_level)
		return

	# Remember that this level has shown its tutorial
	GameManager.tutorial_seen_levels[current_level] = true

	show_tutorial()


func show_tutorial() -> void:
	tutorial_active = true

	# Freeze player
	var player = get_tree().get_first_node_in_group("player")

	if player:
		player.tutorial_active = true
		player.velocity = Vector2.ZERO

	# Fade IN
	var fade_in := create_tween()

	fade_in.tween_property(
		tutorial_ui,
		"modulate:a",
		1.0,
		0.8
	)

	await fade_in.finished

	print("TUTORIAL APPEARED")


func _input(event: InputEvent) -> void:

	if not tutorial_active:
		return

	# Click anywhere to continue
	if event is InputEventMouseButton:
		if event.pressed:
			close_tutorial()


func close_tutorial() -> void:

	tutorial_active = false
	tutorial_finished = true

	print("TUTORIAL FINISHED!")


	# =========================
	# FADE OUT TUTORIAL
	# =========================

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


	# =========================
	# LOCATION INTRO
	# =========================

	var location_intro = get_tree().get_first_node_in_group("location_intro")

	if location_intro:
		await location_intro.show_location()

	else:
		print("ERROR: LocationIntro NOT FOUND!")


	# =========================
	# SHOW QUEST
	# =========================

	var quest_ui = get_tree().get_first_node_in_group("quest_ui")

	if quest_ui:
		await quest_ui.show_quest()

	else:
		print("ERROR: QuestUI NOT FOUND!")


	# =========================
	# START GAMEPLAY
	# =========================

	var player = get_tree().get_first_node_in_group("player")

	if player:
		player.tutorial_active = false
		player.velocity = Vector2.ZERO

	print("GAMEPLAY STARTED!")
