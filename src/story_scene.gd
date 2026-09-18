extends Control


@export_file("*.tscn") var next_scene: String = "res://src/level_1.tscn"


@onready var story_text: Label = $StoryText
@onready var continue_text: Label = $ContinueText
@onready var skip_button: Button = $SkipButton


var story_pages: Array[String] = [
	"Long ago, a wizard lived in a kingdom surrounded by magic.",

	"One night, a great darkness appeared\nand threatened the kingdom.",

	"The wizard fought to protect his home...\nbut he was defeated.",

	"His life ended,\nbut his story was not over.",

	"He awakened in a strange forest,\nwith no memory of his past.",

	"All he remembered was\na voice calling for help.",

	"Across the forest were mysterious crystals\nknown as Stargems.",

	"To reach the castle, he must collect the Stargems\nand defeat every enemy in his path.",

	"Beyond the forest,\na prince was trapped inside the castle.",

	"With his staff in hand,\nthe wizard began his journey once again."
]


# Final goal message
var goal_text: String = "YOUR GOAL\n\nDefeat all the enemies.\nCollect the required Stargems.\nSave the prince.\n\nYour journey begins now."


var current_page: int = 0
var typing: bool = false
var skip_typing: bool = false
var showing_goal: bool = false
var changing_scene: bool = false


func _ready() -> void:

	# Center story text
	story_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	story_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Center continue text
	continue_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Start hidden
	story_text.modulate.a = 0.0
	continue_text.modulate.a = 0.0

	# Connect skip button
	if not skip_button.pressed.is_connected(_on_skip_pressed):
		skip_button.pressed.connect(_on_skip_pressed)

	# Show first story page
	show_page()


func _unhandled_input(event: InputEvent) -> void:

	if changing_scene:
		return

	if event.is_action_pressed("ui_accept"):

		# If currently typing, Space finishes the text
		if typing:

			skip_typing = true

		else:

			# If goal is showing, Space starts the game
			if showing_goal:

				finish_story()

			else:

				next_page()


func show_page() -> void:

	if changing_scene:
		return

	# Check if story is finished
	if current_page >= story_pages.size():

		show_goal()

		return

	print("SHOWING STORY PAGE: ", current_page + 1)

	typing = true
	skip_typing = false

	continue_text.modulate.a = 0.0

	# Fade out old text
	var fade_out := create_tween()

	fade_out.tween_property(
		story_text,
		"modulate:a",
		0.0,
		0.2
	)

	await fade_out.finished

	if changing_scene:
		return

	# Set new story text
	story_text.text = story_pages[current_page]

	story_text.visible_characters = 0

	# Fade in new text
	var fade_in := create_tween()

	fade_in.tween_property(
		story_text,
		"modulate:a",
		1.0,
		0.4
	)

	await fade_in.finished

	if changing_scene:
		return

	# Type text
	await type_text()

	if changing_scene:
		return

	typing = false

	# Show continue message
	continue_text.text = "Press SPACE to continue"
	continue_text.modulate.a = 1.0


func type_text() -> void:

	var full_text: String = story_text.text

	story_text.visible_characters = 0

	for i in range(full_text.length()):

		if changing_scene:
			return

		if skip_typing:

			story_text.visible_characters = -1
			return

		story_text.visible_characters = i + 1

		await get_tree().create_timer(0.025).timeout

	# Make sure everything is visible
	story_text.visible_characters = -1


func next_page() -> void:

	if changing_scene:
		return

	if typing:
		return

	if showing_goal:
		return

	continue_text.modulate.a = 0.0

	current_page += 1

	print("GOING TO PAGE: ", current_page + 1)

	show_page()


func show_goal() -> void:

	if changing_scene:
		return

	if showing_goal:
		return

	showing_goal = true
	typing = true
	skip_typing = false

	print("SHOWING GOAL")


	continue_text.modulate.a = 0.0

	# Fade out previous story text
	var fade_out := create_tween()

	fade_out.tween_property(
		story_text,
		"modulate:a",
		0.0,
		0.3
	)

	await fade_out.finished

	if changing_scene:
		return

	# Set goal text
	story_text.text = goal_text
	story_text.visible_characters = 0

	# Fade in
	var fade_in := create_tween()

	fade_in.tween_property(
		story_text,
		"modulate:a",
		1.0,
		0.5
	)

	await fade_in.finished

	if changing_scene:
		return

	# Type goal
	await type_text()

	if changing_scene:
		return

	typing = false

	# Show start message
	continue_text.text = "Press SPACE to begin"
	continue_text.modulate.a = 1.0


func _on_skip_pressed() -> void:

	if changing_scene:
		return

	print("STORY SKIPPED")

	# Skip directly to the goal
	show_goal()


func finish_story() -> void:

	if changing_scene:
		return

	changing_scene = true

	print("STORY FINISHED")
	print("STARTING LEVEL 1")


	# Hide continue text
	continue_text.modulate.a = 0.0

	# Fade entire story scene
	var fade := create_tween()

	fade.tween_property(
		self,
		"modulate:a",
		0.0,
		1.0
	)

	await fade.finished

	# Go to Level 1
	get_tree().change_scene_to_file(next_scene)
