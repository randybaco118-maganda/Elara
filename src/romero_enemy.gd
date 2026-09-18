extends CharacterBody2D

@export var gravity: float = 1000.0
@export var health: int = 20
@export var speed: float = 170.0
@export var attack_range: float = 100.0
@export var attack_cooldown: float = 1.0
@export var attack_damage: int = 25


var direction: int = 1
var player: Node2D = null

var is_attacking: bool = false
var can_attack: bool = true
var is_dead: bool = false
var is_hurt: bool = false

@onready var health_bar: TextureProgressBar = $TextureProgressBar
@onready var enemy_hp_number: Label = $EnemyHPNumber
@onready var damage_indicator: Label = $DamageIndicator
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# ==========================================
# READY
# ==========================================

func _ready() -> void:
	health_bar.min_value = 0
	health_bar.max_value = health
	health_bar.value = health

	enemy_hp_number.text = str(health) + "/" + str(health)
	
# ==========================================
# PHYSICS
# ==========================================

func _physics_process(_delta: float) -> void:

	# DEAD
	if is_dead:
		return
	
		# GRAVITY
	if not is_on_floor():
		velocity.y += gravity * _delta
	else:
		velocity.y = 0
	# HURT
	if is_hurt:
		velocity.x = 0
		move_and_slide()
		return

	# ATTACKING
	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return


	# ==========================================
	# PLAYER DETECTED
	# ==========================================

	if player != null:

		var distance_to_player: float = global_position.distance_to(
			player.global_position
		)

		print("DISTANCE TO PLAYER: ", distance_to_player)

		# Face the player
		if player.global_position.x < global_position.x:
			direction = -1
			animated_sprite_2d.flip_h = false
		else:
			direction = 1
			animated_sprite_2d.flip_h = true


		# ==========================================
		# ATTACK
		# ==========================================

		if distance_to_player <= attack_range:

			velocity.x = 0

			print("PLAYER IS IN ATTACK RANGE")
			print("ATTACK RANGE: ", attack_range)

			if can_attack:
				print("CALLING ATTACK()")
				attack()


		# ==========================================
		# CHASE PLAYER
		# ==========================================

		else:

			velocity.x = direction * speed
			play_animation("run")


	# ==========================================
	# PATROL
	# ==========================================

	else:

		if ray_cast_right.is_colliding():
			direction = -1

		elif ray_cast_left.is_colliding():
			direction = 1


		velocity.x = direction * speed


		# Face movement direction
		if direction == 1:
			animated_sprite_2d.flip_h = true
		else:
			animated_sprite_2d.flip_h = false


		play_animation("run")


	move_and_slide()


# ==========================================
# ANIMATION HELPER
# ==========================================

func play_animation(animation_name: String) -> void:

	if animated_sprite_2d.animation != animation_name \
	or not animated_sprite_2d.is_playing():

		animated_sprite_2d.play(animation_name)


# ==========================================
# DETECTION AREA
# ==========================================

func _on_detection_area_body_entered(body: Node2D) -> void:

	print("DETECTED SOMETHING: ", body.name)

	if body is CharacterBody2D:

		player = body

		print("PLAYER DETECTED!")


func _on_detection_area_body_exited(body: Node2D) -> void:

	if body == player:

		player = null

		print("PLAYER LOST!")


# ==========================================
# ATTACK
# ==========================================

func attack() -> void:

	if is_dead:
		return

	if is_attacking:
		return

	if not can_attack:
		return

	# Start attack
	is_attacking = true
	can_attack = false
	velocity.x = 0

	print("ENEMY ATTACK!")

	# Play attack animation
	animated_sprite_2d.stop()
	animated_sprite_2d.frame = 0
	animated_sprite_2d.play("attack_smash")

	# Wait a short moment before damage
	await get_tree().create_timer(0.15).timeout

	if is_dead:
		return

	# Check player
	if player != null:

		var distance_to_player: float = global_position.distance_to(
			player.global_position
		)

		if distance_to_player <= attack_range:

			print("ENEMY HIT PLAYER!")

			if player.has_method("take_damage"):
				player.take_damage(attack_damage)

		else:

			print("ENEMY MISSED!")

	# Wait for attack animation to finish
	var attack_time: float = (
		animated_sprite_2d.sprite_frames.get_frame_count("attack_smash")
		/ animated_sprite_2d.sprite_frames.get_animation_speed("attack_smash")
	)

	await get_tree().create_timer(
		max(attack_time - 0.15, 0.0)
	).timeout

	if is_dead:
		return

	# Play ending animation
	animated_sprite_2d.stop()
	animated_sprite_2d.frame = 0
	animated_sprite_2d.play("smash_end")

	var end_time: float = (
		animated_sprite_2d.sprite_frames.get_frame_count("smash_end")
		/ animated_sprite_2d.sprite_frames.get_animation_speed("smash_end")
	)

	await get_tree().create_timer(end_time).timeout

	if is_dead:
		return

	# Attack finished
	is_attacking = false

	# Short cooldown
	await get_tree().create_timer(attack_cooldown).timeout

	if is_dead:
		return

	can_attack = true


# ==========================================
# TAKE DAMAGE
# ==========================================

func take_damage(amount: int) -> void:

	if is_dead:
		return

	if health <= 0:
		return


	health -= amount

	health = max(health, 0)

	health_bar.value = health
	enemy_hp_number.text = str(health) + "/20"
	
	show_damage_indicator(amount)

	print("Flying Wood Enemy HP: ", health)

	# ==========================================
	# DEATH
	# ==========================================

	if health <= 0:

		die()

		return

func show_damage_indicator(amount: int) -> void:

	damage_indicator.text = "-" + str(amount)
	damage_indicator.visible = true
	damage_indicator.modulate.a = 1.0

	# Reset position
	damage_indicator.position = Vector2(-20, -70)

	var tween := create_tween()

	# Move upward
	tween.parallel().tween_property(
		damage_indicator,
		"position",
		Vector2(-20, -100),
		0.5
	)

	# Fade out
	tween.parallel().tween_property(
		damage_indicator,
		"modulate:a",
		0.0,
		0.5
	)

	await tween.finished

	damage_indicator.visible = false
	
	# ==========================================
	# HIT
	# ==========================================

	is_hurt = true
	velocity.x = 0

	print("ENEMY HIT!")


	animated_sprite_2d.play("hit")


	await animated_sprite_2d.animation_finished


	if is_dead:
		return


	is_hurt = false


# ==========================================
# DEATH
# ==========================================

func die() -> void:

	if is_dead:
		return

	is_dead = true
	is_attacking = false
	is_hurt = false

	velocity = Vector2.ZERO

	print("Flying Wood Enemy DIED!")

	# ==========================================
	# TELL LEVEL MANAGER ENEMY WAS DEFEATED
	# ==========================================

	var level_manager = get_tree().get_first_node_in_group("level_manager")

	if level_manager != null:

		if level_manager.has_method("add_enemy_kill"):
			level_manager.add_enemy_kill()
			print("ENEMY KILL REGISTERED!")
		else:
			print("ERROR: LevelManager has no add_enemy_kill() function!")

	else:

		print("ERROR: LEVEL MANAGER NOT FOUND!")

	# ==========================================
	# DISABLE COLLISION
	# ==========================================

	$CollisionShape2D.set_deferred("disabled", true)

	# ==========================================
	# PLAY DEATH ANIMATION
	# ==========================================

	animated_sprite_2d.play("die")

	await animated_sprite_2d.animation_finished

	queue_free()
