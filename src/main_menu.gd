extends Control


func on_start_pressed() -> void:

	print("START GAME")

	# Reset upgrades for a new game
	GameManager.reset_progress()

	# Loading Screen → Story
	SceneLoader.load_scene("res://src/story_scene.tscn")


func _on_option_pressed() -> void:

	print("Settings pressed")


func _on_exit_pressed() -> void:

	get_tree().quit()
