extends Node

# =========================
# QUEST COUNTS
# =========================

var total_stargems: int = 0
var total_enemies: int = 0

var collected_stargems: int = 0
var defeated_enemies: int = 0

var level_complete: bool = false

var quest_ui: Control


# =========================
# READY
# =========================

func _ready() -> void:

	# Add LevelManager to group
	add_to_group("level_manager")

	print("================================")
	print("LEVEL MANAGER STARTING")
	print("CURRENT SCENE: ", get_tree().current_scene.name)
	print("================================")


	# =========================
	# FIND QUEST UI
	# =========================

	quest_ui = get_tree().get_first_node_in_group("quest_ui")

	if quest_ui == null:
		print("QUEST UI GROUP NOT FOUND!")
		print("Trying to find QuestUI by node name...")

		quest_ui = get_tree().current_scene.find_child(
			"QuestUI",
			true,
			false
		)

	if quest_ui != null:
		print("QUEST UI FOUND: ", quest_ui.get_path())
	else:
		print("ERROR: QUEST UI COMPLETELY NOT FOUND!")


	# =========================
	# COUNT STARGEMS
	# =========================

	var stargems_node = get_tree().current_scene.find_child(
		"Stargems",
		true,
		false
	)

	if stargems_node != null:
		total_stargems = stargems_node.get_child_count()
	else:
		total_stargems = 0
		print("WARNING: Stargems node not found!")


	# =========================
	# COUNT ENEMIES
	# =========================

	var enemy_node = get_tree().current_scene.find_child(
		"Enemy",
		true,
		false
	)

	if enemy_node != null:
		total_enemies = enemy_node.get_child_count()
	else:
		total_enemies = 0
		print("WARNING: Enemy node not found!")


	# =========================
	# DEBUG
	# =========================

	print("================================")
	print("TOTAL STARGEMS: ", total_stargems)
	print("TOTAL ENEMIES: ", total_enemies)
	print("QUEST UI: ", quest_ui)
	print("================================")


	# =========================
	# START QUEST
	# =========================

	call_deferred("start_quest")


# =========================
# START QUEST
# =========================

func start_quest() -> void:

	print("STARTING QUEST...")

	if quest_ui == null:
		print("ERROR: QUEST UI IS NULL!")
		return

	print("SHOWING QUEST UI: ", quest_ui.get_path())


	# =========================
	# SHOW QUEST
	# =========================

	if quest_ui.has_method("show_quest"):
		quest_ui.show_quest()
	else:
		quest_ui.visible = true
		quest_ui.modulate.a = 1.0


	# =========================
	# UPDATE QUEST
	# =========================

	update_quest()


# =========================
# STARGEM COLLECTED
# =========================

func add_stargem() -> void:

	collected_stargems += 1

	print(
		"STARGEM COLLECTED: ",
		collected_stargems,
		"/",
		total_stargems
	)

	update_quest()
	check_level_complete()


# =========================
# ENEMY DEFEATED
# =========================

func add_enemy_kill() -> void:

	defeated_enemies += 1

	print(
		"ENEMY DEFEATED: ",
		defeated_enemies,
		"/",
		total_enemies
	)

	update_quest()
	check_level_complete()


# =========================
# UPDATE QUEST
# =========================

func update_quest() -> void:

	if quest_ui == null:
		print("ERROR: QUEST UI NOT FOUND!")
		return

	if quest_ui.has_method("update_quest"):
		quest_ui.update_quest(
			collected_stargems,
			total_stargems,
			defeated_enemies,
			total_enemies
		)
	else:
		print("ERROR: QuestUI has no update_quest() function!")


# =========================
# CHECK LEVEL COMPLETE
# =========================

func check_level_complete() -> void:

	# ALL STARGEMS + ALL ENEMIES
	if collected_stargems >= total_stargems \
	and defeated_enemies >= total_enemies:

		if level_complete:
			return

		level_complete = true

		print("================================")
		print("QUEST COMPLETE!")
		print("ALL STARGEMS COLLECTED!")
		print("ALL ENEMIES DEFEATED!")
		print("================================")
