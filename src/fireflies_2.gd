extends Sprite2D

@export var move_speed := 10.0
@export var float_speed := 2.0
@export var float_amount := 10.0

var start_y: float
var time_passed := 0.0

func _ready() -> void:
	start_y = position.y

func _process(delta: float) -> void:
	time_passed += delta

	position.x += move_speed * delta
	position.y = start_y + sin(time_passed * float_speed) * float_amount
