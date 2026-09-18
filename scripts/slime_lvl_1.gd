extends CharacterBody2D

@export var health: int = 10
@export var speed: float = 60.0

var direction: int = 1

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	# Change direction when hitting something
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite_2d.flip_h = true

	elif ray_cast_left.is_colliding():
		direction = 1
		animated_sprite_2d.flip_h = false

	# Move left/right
	velocity.x = direction * speed

	move_and_slide()


func take_damage(amount: int) -> void:
	var dmg = 5
	if health <= 0:
		return

	health -= dmg
	print("Slime took damage! Current health: ", health)

	if health <= 0:
		die()


func die() -> void:
	print("Slime destroyed!")
	queue_free()
