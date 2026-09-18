extends Area2D


# =========================
# GUARDING ENEMIES
# =========================

var guarding_enemy_1: Node = null
var guarding_enemy_2: Node = null


# =========================
# TREASURE STATE
# =========================

var unlocked: bool = false
var player_near: bool = false
var collected: bool = false


# =========================
# REFERENCES
# =========================

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var open_guide: Label = $OpenGuide


# =========================
# READY
# =========================

func _ready() -> void:

	animated_sprite.play("idle")
	open_guide.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	print("DOUBLE JUMP CHEST READY")


# =========================
# PROCESS
# =========================

func _process(_delta: float) -> void:

	if collected:
		return

	# Find guards
	if guarding_enemy_1 == null:
		guarding_enemy_1 = get_tree().current_scene.find_child(
			"DoubleJumpGuard1",
			true,
			false
		)

	if guarding_enemy_2 == null:
		guarding_enemy_2 = get_tree().current_scene.find_child(
			"DoubleJumpGuard2",
			true,
			false
		)

	# Check if both guards are dead
	if not unlocked:

		var guard1_dead = (
			guarding_enemy_1 == null
			or not is_instance_valid(guarding_enemy_1)
		)

		var guard2_dead = (
			guarding_enemy_2 == null
			or not is_instance_valid(guarding_enemy_2)
		)

		if guard1_dead and guard2_dead:

			unlocked = true

			print("================================")
			print("DOUBLE JUMP TREASURE UNLOCKED!")
			print("BOTH GUARDS DEFEATED!")
			print("================================")

	# Show open guide
	if unlocked and player_near:
		open_guide.visible = true
	else:
		open_guide.visible = false

	# Open treasure
	if unlocked and player_near:

		if Input.is_action_just_pressed("interact"):
			open_treasure()


# =========================
# PLAYER ENTERED
# =========================

func _on_body_entered(body: Node2D) -> void:

	if body.is_in_group("player"):

		player_near = true

		if not unlocked:

			print("DOUBLE JUMP CHEST LOCKED")
			print("DEFEAT BOTH GUARDS FIRST")


# =========================
# PLAYER EXITED
# =========================

func _on_body_exited(body: Node2D) -> void:

	if body.is_in_group("player"):

		player_near = false
		open_guide.visible = false


# =========================
# OPEN TREASURE
# =========================

func open_treasure() -> void:

	if collected:
		return

	if not unlocked:

		print("DOUBLE JUMP CHEST LOCKED!")
		return

	collected = true
	open_guide.visible = false

	print("OPENING DOUBLE JUMP TREASURE!")

	# Find player
	var player = get_tree().get_first_node_in_group("player")

	if player:

		player.is_getting_treasure = true
		player.velocity = Vector2.ZERO

		# =========================
		# UNLOCK DOUBLE JUMP
		# =========================

		if player.has_method("unlock_double_jump"):

			player.unlock_double_jump()

			print("DOUBLE JUMP UNLOCKED ON PLAYER!")

		else:

			print("ERROR: unlock_double_jump() NOT FOUND!")

	# =========================
	# PLAY OPEN ANIMATION
	# =========================

	animated_sprite.play("open")

	await animated_sprite.animation_finished

	# =========================
	# SHOW TREASURE UI
	# =========================

	var treasure_ui = get_tree().get_first_node_in_group("treasure_ui")

	if treasure_ui:

		print("TREASURE UI FOUND!")

		treasure_ui.show_double_jump()

	else:

		print("ERROR: TREASURE UI NOT FOUND!")
		print("Make sure TreasureUI is in group: treasure_ui")

	# =========================
	# REMOVE CHEST
	# =========================

	queue_free()
