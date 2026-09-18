class_name PlayerUseAbilityComponent
extends Node

@export var use_ability_action_name: String = "use_ability"
@export var ability: Ability
@export var user: Node2D


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed(use_ability_action_name):
		return

	print("=== ABILITY INPUT ===")

	if user == null:
		print("ERROR: USER IS NOT ASSIGNED!")
		return

	if ability == null:
		print("ERROR: ABILITY IS NOT ASSIGNED!")
		return

	print("USER: ", user.name)
	print("ABILITY: ", ability)

	# =========================
	# CHECK IF PLAYER CAN ATTACK
	# =========================

	if user.has_method("can_attack"):

		if not user.can_attack():
			print("CANNOT ATTACK - NOT ENOUGH MANA!")
			return

	else:
		print("ERROR: can_attack() NOT FOUND!")
		return

	# =========================
	# START ATTACK
	# =========================

	user.attack()
	print("ATTACK FUNCTION CALLED!")

	# =========================
	# CREATE PROJECTILE
	# =========================

	var success := ability.use(user)

	print("PROJECTILE RESULT: ", success)
