extends CharacterBody2D

# =========================
# PLAYER SETTINGS
# =========================

@export var speed: float = 500.0
@export var jump_force: float = 1300.0
@export var gravity: float = 3200.0
@export var fall_gravity_multiplier: float = 1.5

var is_attacking: bool = false


# =========================
# HP
# =========================

@export var max_health: int = 100
var health: int = 100

@export var health_regen_amount: int = 2
@export var health_regen_interval: float = 1.0

var health_regen_timer: float = 0.0


# =========================
# MP
# =========================

@export var max_mana: int = 100
@export var mana_cost_per_attack: int = 10

@export var mana_regen_amount: int = 10
@export var mana_regen_interval: float = 1.0

var mana: int = 100
var mana_regen_timer: float = 0.0


var tutorial_active: bool = false


# =========================
# REFERENCES
# =========================

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var death_screen: ColorRect = $DeathUI/DeathScreen
@onready var you_died: Label = $DeathUI/DeathScreen/YouDied

@onready var no_mana_text: Label = $"../HUD/PlayerStatus/NoManaText"
@onready var hp_number: Label = $"../HUD/PlayerStatus/HPNumber"
@onready var mp_number: Label = $"../HUD/PlayerStatus/MPNumber"


# =========================
# SOUNDFX
# =========================

@onready var jump_sfx = $JumpSFX
@onready var attack_sfx = $AttackSFX
@onready var hurt_sfx = $HurtSFX


# =========================
# PLAYER STATE
# =========================

var is_getting_treasure: bool = false

var direction := Vector2.RIGHT
var facing_direction: float = 1.0

var is_dead: bool = false
var is_hurt: bool = false


# =========================
# TREASURE UPGRADES
# =========================

var has_double_jump: bool = false
var double_jump_used: bool = false

var has_triple_shot: bool = false


# =========================
# READY
# =========================

func _ready() -> void:

	health = max_health
	mana = max_mana
	
	# =========================
	# LOAD SAVED UPGRADES
	# =========================

	has_double_jump = GameManager.has_double_jump
	has_triple_shot = GameManager.has_triple_shot

	print("===== PLAYER UPGRADES =====")
	print("DOUBLE JUMP: ", has_double_jump)
	print("TRIPLE SHOT: ", has_triple_shot)

	no_mana_text.visible = false

	# Hide death screen
	death_screen.color.a = 0.0
	you_died.modulate.a = 0.0

	animated_sprite.play("idle")

	print("PLAYER HP: ", health)
	print("PLAYER MP: ", mana)


# =========================
# PHYSICS
# =========================

func _physics_process(delta: float) -> void:

	# =========================
	# TUTORIAL
	# =========================

	if tutorial_active:
		velocity = Vector2.ZERO
		move_and_slide()
		return


	# =========================
	# DEAD
	# =========================

	if is_dead:
		return


	# =========================
	# GETTING TREASURE
	# =========================

	if is_getting_treasure:
		velocity = Vector2.ZERO
		move_and_slide()
		return


	# =========================
	# HUD
	# =========================

	hp_number.text = str(health) + "/" + str(max_health)
	mp_number.text = str(mana) + "/" + str(max_mana)


	# =========================
	# HP REGENERATION
	# =========================

	if health < max_health:

		health_regen_timer += delta

		if health_regen_timer >= health_regen_interval:

			health += health_regen_amount
			health = min(health, max_health)

			health_regen_timer = 0.0

			print("HP RECOVERED: ", health)


	# =========================
	# MP REGENERATION
	# =========================

	if mana < max_mana:

		mana_regen_timer += delta

		if mana_regen_timer >= mana_regen_interval:

			mana += mana_regen_amount
			mana = min(mana, max_mana)

			mana_regen_timer = 0.0

			print("MP RECOVERED: ", mana)


	# =========================
	# GRAVITY
	# =========================

	if not is_on_floor():

		if velocity.y > 0:
			velocity.y += gravity * fall_gravity_multiplier * delta
		else:
			velocity.y += gravity * delta

	else:
		# Reset double jump when on floor
		double_jump_used = false


	# =========================
	# MOVEMENT
	# =========================

	var input_x := Input.get_axis("left", "right")

	velocity.x = input_x * speed


	# =========================
	# FACING
	# =========================

	if input_x != 0:

		facing_direction = input_x

		direction = Vector2(input_x, 0)

		animated_sprite.flip_h = input_x < 0


	# =========================
	# JUMP
	# =========================

	if Input.is_action_just_pressed("jump"):

		# NORMAL JUMP
		if is_on_floor():

			velocity.y = -jump_force

			double_jump_used = false

			jump_sfx.play()

			print("NORMAL JUMP!")


		# DOUBLE JUMP
		elif has_double_jump and not double_jump_used:

			velocity.y = -jump_force

			double_jump_used = true

			jump_sfx.play()

			print("DOUBLE JUMP USED!")


	# =========================
	# MOVE PLAYER
	# =========================

	move_and_slide()


	# =========================
	# ANIMATIONS
	# =========================

	if is_hurt:
		return

	if is_attacking:
		return

	if not is_on_floor():

		animated_sprite.play("jump")

	elif input_x != 0:

		animated_sprite.play("run")

	else:

		animated_sprite.play("idle")


# =========================
# PLAYER ATTACK
# =========================

func can_attack() -> bool:

	if is_dead:
		return false

	if is_hurt:
		return false

	if is_attacking:
		return false

	if mana < mana_cost_per_attack:

		print("NOT ENOUGH MANA!")

		show_no_mana()

		return false

	return true


func attack() -> void:

	if is_dead:
		return

	if is_getting_treasure:
		return

	if is_hurt:
		return

	if is_attacking:
		return

	# =========================
	# CHECK MANA
	# =========================

	if mana < mana_cost_per_attack:

		print("NOT ENOUGH MANA!")

		show_no_mana()

		return


	# =========================
	# CONSUME MANA
	# =========================

	mana -= mana_cost_per_attack

	print("PLAYER ATTACK!")
	print("MANA USED: ", mana_cost_per_attack)
	print("CURRENT MANA: ", mana)


	# =========================
	# ATTACK STATE
	# =========================

	is_attacking = true

	attack_sfx.play()


	# =========================
	# ATTACK ANIMATION
	# =========================

	if animated_sprite.sprite_frames.has_animation("attack"):

		animated_sprite.stop()

		animated_sprite.frame = 0

		animated_sprite.sprite_frames.set_animation_loop(
			"attack",
			false
		)

		animated_sprite.play("attack")

		await animated_sprite.animation_finished

	else:

		print("ERROR: 'attack' animation not found!")


	is_attacking = false

	print("PLAYER ATTACK FINISHED")


# =========================
# TAKE DAMAGE / HIT
# =========================

func take_damage(amount: int) -> void:

	if is_dead:
		return

	if is_hurt:
		return

	health -= amount

	print("PLAYER TOOK DAMAGE: ", amount)
	print("PLAYER HP: ", health)


	# =========================
	# DEATH
	# =========================

	if health <= 0:

		health = 0

		die()

		return


	# =========================
	# HURT STATE
	# =========================

	is_hurt = true

	is_attacking = false

	velocity.x = 0

	hurt_sfx.play()

	hit_flash()

	print("PLAYER HURT!")


	if animated_sprite.sprite_frames.has_animation("hurt"):

		animated_sprite.sprite_frames.set_animation_loop(
			"hurt",
			false
		)

		animated_sprite.stop()

		animated_sprite.frame = 0

		animated_sprite.play("hurt")

		await animated_sprite.animation_finished

	else:

		print("ERROR: 'hurt' animation not found!")

		await get_tree().create_timer(0.2).timeout


	# =========================
	# RETURN TO NORMAL
	# =========================

	if not is_dead:

		is_hurt = false

		print("PLAYER HURT FINISHED")


# =========================
# HIT FLASH
# =========================

func hit_flash() -> void:

	animated_sprite.modulate = Color(1, 0.2, 0.2)

	await get_tree().create_timer(0.1).timeout

	animated_sprite.modulate = Color.WHITE


# =========================
# PLAYER DEATH
# =========================

func die() -> void:

	if is_dead:
		return


	# =========================
	# COUNT ENEMY DEFEAT
	# =========================

	var level_manager = get_tree().get_first_node_in_group("level_manager")

	if level_manager:

		level_manager.add_enemy_kill()

		print("ENEMY COUNTED!")

	else:

		print("ERROR: LEVEL MANAGER NOT FOUND!")


	# =========================
	# DEATH STATE
	# =========================

	is_dead = true

	is_hurt = false

	is_attacking = false

	velocity = Vector2.ZERO

	print("PLAYER DIED!")


	# =========================
	# DISABLE COLLISION
	# =========================

	$CollisionShape2D.set_deferred("disabled", true)


	# =========================
	# DEATH ANIMATION
	# =========================

	if animated_sprite.sprite_frames.has_animation("die"):

		animated_sprite.play("die")

		await animated_sprite.animation_finished

	else:

		print("ERROR: 'die' animation not found!")

		await get_tree().create_timer(0.2).timeout


	# =========================
	# FADE SCREEN
	# =========================

	print("FADING SCREEN...")

	var fade_tween := create_tween()

	fade_tween.tween_property(
		death_screen,
		"color:a",
		0.85,
		0.3
	)

	await fade_tween.finished


	# =========================
	# YOU DIED
	# =========================

	print("YOU DIED!")

	var text_tween := create_tween()

	text_tween.tween_property(
		you_died,
		"modulate:a",
		1.0,
		0.2
	)

	await text_tween.finished


	# =========================
	# WAIT
	# =========================

	await get_tree().create_timer(1.0).timeout


	# =========================
	# RESTART
	# =========================

	print("RESTARTING LEVEL...")

	get_tree().reload_current_scene()


# =========================
# NO MANA
# =========================

func show_no_mana() -> void:

	no_mana_text.visible = true

	await get_tree().create_timer(1.0).timeout

	no_mana_text.visible = false


# =========================
# UNLOCK DOUBLE JUMP
# =========================

func unlock_double_jump() -> void:

	has_double_jump = true

	double_jump_used = false

	GameManager.has_double_jump = true

	print("DOUBLE JUMP ACQUIRED!")

	print("DOUBLE JUMP SAVED TO GAMEMANAGER!")


# =========================
# UNLOCK TRIPLE SHOT
# =========================

func unlock_triple_shot() -> void:

	has_triple_shot = true

	GameManager.has_triple_shot = true

	print("TRIPLE SHOT ACQUIRED!")

	print("TRIPLE SHOT SAVED TO GAMEMANAGER!")
