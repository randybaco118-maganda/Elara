extends Area2D


# =========================
# GUARDING ENEMIES
# =========================

@export var guarding_enemy_1: Node2D
@export var guarding_enemy_2: Node2D
@export var guarding_enemy_3: Node2D
@export var guarding_enemy_4: Node2D


# =========================
# TREASURE STATE
# =========================

var unlocked: bool = false
var player_near: bool = false
var collected: bool = false
var guards_assigned: bool = false


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

	# Check that all 4 enemies were assigned
	if guarding_enemy_1 == null:
		print("ERROR: Triple Shot Guard 1 is NOT assigned!")
		return

	if guarding_enemy_2 == null:
		print("ERROR: Triple Shot Guard 2 is NOT assigned!")
		return

	if guarding_enemy_3 == null:
		print("ERROR: Triple Shot Guard 3 is NOT assigned!")
		return

	if guarding_enemy_4 == null:
		print("ERROR: Triple Shot Guard 4 is NOT assigned!")
		return

	guards_assigned = true

	print("===== TRIPLE SHOT CHEST =====")
	print("Guard 1: ", guarding_enemy_1.name)
	print("Guard 2: ", guarding_enemy_2.name)
	print("Guard 3: ", guarding_enemy_3.name)
	print("Guard 4: ", guarding_enemy_4.name)
	print("ALL 4 GUARDS ASSIGNED!")


# =========================
# PROCESS
# =========================

func _process(_delta: float) -> void:
	if collected:
		return

	if not guards_assigned:
		return

	# Unlock ONLY when ALL 4 enemies are dead
	if not unlocked:
		var guard1_dead = not is_instance_valid(guarding_enemy_1)
		var guard2_dead = not is_instance_valid(guarding_enemy_2)
		var guard3_dead = not is_instance_valid(guarding_enemy_3)
		var guard4_dead = not is_instance_valid(guarding_enemy_4)

		if guard1_dead and guard2_dead and guard3_dead and guard4_dead:
			unlocked = true

			print("==============================")
			print("TRIPLE SHOT TREASURE UNLOCKED!")
			print("ALL 4 GUARDS DEFEATED!")
			print("==============================")


	# Show F guide
	if unlocked and player_near:
		open_guide.visible = true
	else:
		open_guide.visible = false


	# Open chest
	if unlocked and player_near:
		if Input.is_action_just_pressed("interact"):
			open_treasure()


# =========================
# PLAYER ENTERED
# =========================

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = true


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
		return

	collected = true
	open_guide.visible = false

	print("OPENING TRIPLE SHOT TREASURE!")


	# Find player
	var player = get_tree().get_first_node_in_group("player")

	if player:
		player.is_getting_treasure = true
		player.velocity = Vector2.ZERO

		# Unlock Triple Shot
		if player.has_method("unlock_triple_shot"):
			player.unlock_triple_shot()
			print("TRIPLE SHOT UNLOCKED ON PLAYER!")
		else:
			print("ERROR: unlock_triple_shot() NOT FOUND!")


	# Open chest animation
	animated_sprite.play("open")

	await animated_sprite.animation_finished


	# Find Treasure UI
	var treasure_ui = get_tree().get_first_node_in_group("treasure_ui")

	if treasure_ui:
		print("TREASURE UI FOUND!")
		treasure_ui.show_triple_shot()
	else:
		print("ERROR: TREASURE UI NOT FOUND!")
		print("Make sure TreasureUI is in group: treasure_ui")


	# Remove chest
	queue_free()
