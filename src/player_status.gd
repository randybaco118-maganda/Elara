extends Control

@export var player: Node

@onready var hp_bar: TextureProgressBar = $HPBar
@onready var mp_bar: TextureProgressBar = $MPBar


func _ready() -> void:
	if player == null:
		print("ERROR: Player is not assigned!")
		return

	# HP
	hp_bar.min_value = 0
	hp_bar.max_value = player.max_health
	hp_bar.value = player.health

	# MP
	mp_bar.min_value = 0
	mp_bar.max_value = player.max_mana
	mp_bar.value = player.mana


func _process(_delta: float) -> void:
	if player == null:
		return

	# HP
	hp_bar.max_value = player.max_health
	hp_bar.value = player.health

	# MP
	mp_bar.max_value = player.max_mana
	mp_bar.value = player.mana
