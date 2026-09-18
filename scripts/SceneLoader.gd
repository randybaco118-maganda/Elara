extends Node


func load_scene(scene_path: String) -> void:

	print("================================")
	print("LOADING SCENE")
	print("TARGET: ", scene_path)
	print("================================")


	# Create loading screen
	var loading_screen = preload(
		"res://loading_screen.tscn"
	).instantiate()


	# Tell loading screen what scene to load
	loading_screen.next_scene = scene_path


	# Add loading screen
	get_tree().root.add_child(loading_screen)


	# Remove current scene
	if get_tree().current_scene:

		get_tree().current_scene.queue_free()


	# Make loading screen current scene
	get_tree().current_scene = loading_screen
