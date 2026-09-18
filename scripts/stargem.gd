extends Area2D

@onready var pickup_sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D

var collected: bool = false


func _on_body_entered(body: Node2D) -> void:

	if collected:
		return

	if body.name == "Player" or body.is_in_group("player"):

		collected = true

		print("+1 STARGEM!")

		var level_manager = get_tree().get_first_node_in_group("level_manager")

		if level_manager:
			level_manager.add_stargem()
		else:
			print("ERROR: LevelManager not found!")

		set_deferred("monitoring", false)

		hide()

		pickup_sfx.play()

		await pickup_sfx.finished

		queue_free()

		# Play pickup sound
		pickup_sfx.play()

		await pickup_sfx.finished

		queue_free()
