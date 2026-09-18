extends Area2D


@export_file("*.tscn") var next_level: String = "res://src/level_2.tscn"


@onready var portal: AnimatedSprite2D = $AnimatedSprite2D
@onready var teleport_guide: Label = $TeleportGuide


var player_nearby: bool = false
var teleporting: bool = false


func _ready() -> void:

	# Keep portal on the first frame
	portal.animation = "teleport"
	portal.frame = 0

	# Hide teleport guide
	teleport_guide.visible = false

	# Connect Area2D signals
	body_entered.connect(_on_interaction_area_body_entered)
	body_exited.connect(_on_interaction_area_body_exited)


func _process(_delta: float) -> void:

	if player_nearby and not teleporting:

		if Input.is_action_just_pressed("teleport"):
			start_teleport()


func _on_interaction_area_body_entered(body: Node2D) -> void:

	if body.is_in_group("player"):

		player_nearby = true

		var level_manager = get_tree().get_first_node_in_group("level_manager")

		if level_manager and level_manager.level_complete:

			teleport_guide.text = "Press G to Teleport"
			teleport_guide.visible = true

			print("PLAYER ENTERED TELEPORT AREA - QUEST COMPLETE")

		else:

			teleport_guide.text = "Complete the Quest First"
			teleport_guide.visible = true

			print("PLAYER ENTERED TELEPORT AREA - QUEST NOT COMPLETE")


func _on_interaction_area_body_exited(body: Node2D) -> void:

	if body.is_in_group("player"):

		player_nearby = false
		teleport_guide.visible = false

		print("PLAYER LEFT TELEPORT AREA")


func start_teleport() -> void:

	if teleporting:
		return


	# =================================
	# CHECK QUEST
	# =================================

	var level_manager = get_tree().get_first_node_in_group("level_manager")

	if level_manager == null:

		print("ERROR: LEVEL MANAGER NOT FOUND!")

		return


	if not level_manager.level_complete:

		print("TELEPORT BLOCKED - QUEST NOT COMPLETE!")

		teleport_guide.text = "Complete the Quest First"

		return


	# =================================
	# START TELEPORT
	# =================================

	teleporting = true

	teleport_guide.visible = false

	print("QUEST COMPLETE!")
	print("STARTING TELEPORT...")


	# =================================
	# FIND PLAYER
	# =================================

	var player = get_tree().get_first_node_in_group("player")


	# Stop player movement
	if player:

		player.set_physics_process(false)


	# =================================
	# PLAY TELEPORT ANIMATION
	# =================================

	portal.play("teleport")


	# Wait until animation finishes
	await portal.animation_finished


	# =================================
	# LOAD NEXT LEVEL
	# =================================

	print("LOADING NEXT LEVEL: ", next_level)

	SceneLoader.load_scene(next_level)
