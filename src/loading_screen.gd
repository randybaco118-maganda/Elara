extends Control


var next_scene: String = "res://src/level_1.tscn"


@onready var loading_text: Label = $LoadingText
@onready var progress_bar: ProgressBar = $ProgressBar


func _ready() -> void:

	loading_text.text = "LOADING..."
	loading_text.modulate.a = 1.0

	progress_bar.value = 0


	# Loading text animation
	var text_tween := create_tween()

	text_tween.set_loops()

	text_tween.tween_property(
		loading_text,
		"modulate:a",
		0.3,
		0.6
	)

	text_tween.tween_property(
		loading_text,
		"modulate:a",
		1.0,
		0.6
	)


	# Progress bar
	var progress_tween := create_tween()

	progress_tween.tween_property(
		progress_bar,
		"value",
		100.0,
		2.0
	)

	await progress_tween.finished


	print("LOADING COMPLETE")
	print("NEXT SCENE: ", next_scene)


	get_tree().change_scene_to_file(next_scene)
