extends Area2D

@export var speed: float = 700.0
@export var damage: int = 5

var direction := Vector2.RIGHT


func _ready() -> void:
	print("WIND PROJECTILE READY!")


# =========================
# NORMAL / HORIZONTAL SHOT
# =========================

func launch(facing_direction: float) -> void:

	direction = Vector2(
		facing_direction,
		0
	)

	print("PROJECTILE LAUNCHED!")
	print("DIRECTION: ", direction)


# =========================
# TRIPLE SHOT DIRECTION
# =========================

func launch_direction(new_direction: Vector2) -> void:

	direction = new_direction.normalized()

	print("PROJECTILE LAUNCHED!")
	print("DIRECTION: ", direction)


# =========================
# MOVEMENT
# =========================

func _physics_process(delta: float) -> void:

	position += direction * speed * delta


# =========================
# COLLISION
# =========================

func _on_body_entered(body: Node2D) -> void:

	print("PROJECTILE HIT: ", body.name)

	if body.is_in_group("flyingwoodenemy"):

		print("HIT FLYING WOOD ENEMY!")

		if body.has_method("take_damage"):
			body.take_damage(damage)

		queue_free()
		return


	if body is TileMapLayer:

		print("HIT TILE!")

		queue_free()
