extends CharacterBody2D

@export var health: int = 20
@export var speed: float = 60.0

var direction: int = 1

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	# Detect obstacle/enemy on the right
	if ray_cast_right.is_colliding():
		direction = -1

	# Detect obstacle/enemy on the left
	elif ray_cast_left.is_colliding():
		direction = 1


	# Sprite direction
	# Your sprite's default direction faces LEFT.
	if direction == 1:
		# Moving RIGHT
		animated_sprite_2d.flip_h = true
	else:
		# Moving LEFT
		animated_sprite_2d.flip_h = false


	# Movement
	velocity.x = direction * speed
	move_and_slide()


func take_damage(amount: int) -> void:
	if health <= 0:
		return

	health -= amount

	print("Flying Wood Enemy HP: ", health)

	if health <= 0:
		die()


func die() -> void:
	print("Flying Wood Enemy defeated!")
	queue_free()
