extends Area2D


func _on_body_entered(body: Node2D) -> void:

	print("KillZone detected: ", body.name)

	if body.is_in_group("player"):
		print("PLAYER ENTERED KILLZONE!")
		body.die()
