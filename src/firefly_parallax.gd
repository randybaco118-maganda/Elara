extends Parallax2D

@export var move_speed: float = 15.0
@export var image_width: float = 1920.0

func _process(delta: float) -> void:
	scroll_offset.x += move_speed * delta

	if scroll_offset.x >= image_width:
		scroll_offset.x -= image_width
