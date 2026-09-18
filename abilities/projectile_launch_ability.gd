class_name ProjectileLaunchAbility
extends Ability

@export var projectile_scene: PackedScene
@export var instancing_offset: Vector2 = Vector2(50, 0)

# Angle between the three shots
@export var triple_shot_angle: float = 15.0


func use(p_user: Node2D) -> bool:

	if p_user == null:
		push_error("ProjectileLaunchAbility: User is null!")
		return false

	if projectile_scene == null:
		push_error("ProjectileLaunchAbility: No projectile scene assigned!")
		return false

	var facing: float = p_user.facing_direction


	# =========================
	# NORMAL ATTACK
	# =========================

	if not p_user.has_triple_shot:

		create_projectile(
			p_user,
			facing,
			0.0
		)

		print("NORMAL SHOT!")

		return true


	# =========================
	# TRIPLE SHOT
	# =========================

	print("TRIPLE SHOT!")

	# Center projectile
	create_projectile(
		p_user,
		facing,
		0.0
	)

	# Upper projectile
	create_projectile(
		p_user,
		facing,
		-triple_shot_angle
	)

	# Lower projectile
	create_projectile(
		p_user,
		facing,
		triple_shot_angle
	)

	return true


# =========================
# CREATE PROJECTILE
# =========================

func create_projectile(
	p_user: Node2D,
	facing: float,
	angle: float
) -> void:

	var instance = projectile_scene.instantiate()

	if instance == null:
		push_error("ProjectileLaunchAbility: Failed to instantiate projectile!")
		return

	p_user.get_parent().add_child(instance)

	# Spawn projectile in front of player
	instance.global_position = p_user.global_position + Vector2(
		instancing_offset.x * facing,
		instancing_offset.y
	)

	# Calculate projectile direction
	var direction := Vector2(facing, 0).rotated(
		deg_to_rad(angle)
	)

	# Tell projectile which direction to travel
	instance.launch_direction(direction)

	print("PROJECTILE CREATED!")
	print("DIRECTION: ", direction)
