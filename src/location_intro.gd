extends CanvasLayer

@export var location_name: String = "FOREST OF DEATH - UPPER GROUND"

@onready var location_ui: Control = $LocationUI

var is_showing: bool = false


func _ready() -> void:
	# Hide when the level starts
	visible = false

	# Start transparent
	location_ui.modulate.a = 0.0


func show_location() -> void:
	# Prevent multiple location intros
	if is_showing:
		return

	is_showing = true
	visible = true

	print("SHOWING LOCATION: ", location_name)

	# Make sure it starts transparent
	location_ui.modulate.a = 0.0

	# Fade IN
	var fade_in := create_tween()

	fade_in.tween_property(
		location_ui,
		"modulate:a",
		1.0,
		0.8
	)

	fade_in.finished.connect(_location_stay)


func _location_stay() -> void:
	# Stay visible for 2 seconds
	await get_tree().create_timer(2.0).timeout

	# Fade OUT
	var fade_out := create_tween()

	fade_out.tween_property(
		location_ui,
		"modulate:a",
		0.0,
		0.8
	)

	fade_out.finished.connect(_location_finished)


func _location_finished() -> void:
	visible = false
	is_showing = false

	print("LOCATION INTRO FINISHED")
