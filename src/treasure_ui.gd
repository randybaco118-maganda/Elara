extends CanvasLayer

@onready var treasure_panel: Panel = $TreasurePanel
@onready var upgrade_name: Label = $TreasurePanel/UpgradeName
@onready var how_to_use: Label = $TreasurePanel/HowToUse
@onready var description: Label = $TreasurePanel/Description

var showing_treasure: bool = false


# =========================
# READY
# =========================

func _ready() -> void:
	treasure_panel.visible = false


# =========================
# SHOW DOUBLE JUMP
# =========================

func show_double_jump() -> void:
	upgrade_name.text = "Double Jump"
	how_to_use.text = "Press Space again while in the air to double jump!"
	description.text = "You can now jump twice in the air!"
	treasure_panel.visible = true
	showing_treasure = true


# =========================
# SHOW TRIPLE SHOT
# =========================

func show_triple_shot() -> void:
	upgrade_name.text = "Triple Shot"
	how_to_use.text = "Press your attack button to fire three shots!"
	description.text = "You can now fire three projectiles at once!"
	treasure_panel.visible = true
	showing_treasure = true


# =========================
# INPUT
# =========================

func _input(event: InputEvent) -> void:

	if not showing_treasure:
		return

	# LEFT CLICK ANYWHERE
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			close_treasure()
			return

	# ENTER OR SPACE
	if event.is_action_pressed("ui_accept"):
		close_treasure()


# =========================
# CLOSE TREASURE UI
# =========================

func close_treasure() -> void:

	if not showing_treasure:
		return

	treasure_panel.visible = false
	showing_treasure = false

	# Allow player to move again
	var player = get_tree().get_first_node_in_group("player")

	if player:
		player.is_getting_treasure = false
		player.velocity = Vector2.ZERO

	print("TREASURE UI CLOSED")
