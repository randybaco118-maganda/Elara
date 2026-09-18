extends Control

@onready var quest_instruction: Label = $QuestInstruction
@onready var stargem_quest: Label = $StargemQuest
@onready var enemy_quest: Label = $EnemyQuest

var quest_visible: bool = false
var quest_completed: bool = false


func _ready() -> void:

	# Hide Quest UI when level starts
	visible = false
	modulate.a = 0.0

	# Default colors
	quest_instruction.add_theme_color_override(
		"font_color",
		Color.WHITE
	)

	stargem_quest.add_theme_color_override(
		"font_color",
		Color.WHITE
	)

	enemy_quest.add_theme_color_override(
		"font_color",
		Color.WHITE
	)


func show_quest() -> void:

	if quest_visible:
		return

	quest_visible = true
	visible = true
	modulate.a = 0.0

	var fade_in := create_tween()

	fade_in.tween_property(
		self,
		"modulate:a",
		1.0,
		0.8
	)

	await fade_in.finished

	print("QUEST UI FADED IN")


func update_quest(
	collected_stargems: int,
	total_stargems: int,
	defeated_enemies: int,
	total_enemies: int
) -> void:

	# =================================
	# STARGEM QUEST
	# ALL STARGEMS REQUIRED
	# =================================

	var stargems_complete: bool = (
		collected_stargems >= total_stargems
	)

	if stargems_complete:

		stargem_quest.text = (
			"✓ Collect all Stargems\n"
			+ str(collected_stargems)
			+ " / "
			+ str(total_stargems)
		)

		stargem_quest.add_theme_color_override(
			"font_color",
			Color("#66FF66")
		)

	else:

		stargem_quest.text = (
			"Collect all Stargems\n"
			+ str(collected_stargems)
			+ " / "
			+ str(total_stargems)
		)

		stargem_quest.add_theme_color_override(
			"font_color",
			Color.WHITE
		)


	# =================================
	# ENEMY QUEST
	# ALL ENEMIES REQUIRED
	# =================================

	var enemies_complete: bool = (
		defeated_enemies >= total_enemies
	)

	if enemies_complete:

		enemy_quest.text = (
			"✓ Defeat all Enemies\n"
			+ str(defeated_enemies)
			+ " / "
			+ str(total_enemies)
		)

		enemy_quest.add_theme_color_override(
			"font_color",
			Color("#66FF66")
		)

	else:

		enemy_quest.text = (
			"Defeat all Enemies\n"
			+ str(defeated_enemies)
			+ " / "
			+ str(total_enemies)
		)

		enemy_quest.add_theme_color_override(
			"font_color",
			Color.WHITE
		)


	# =================================
	# QUEST COMPLETE
	# =================================

	if stargems_complete and enemies_complete:

		quest_completed = true

		quest_instruction.text = (
			"✓ Quest Complete"
		)

		quest_instruction.add_theme_color_override(
			"font_color",
			Color("#66FF66")
		)

	else:

		quest_completed = false

		quest_instruction.text = (
			"Complete this quest"
		)

		quest_instruction.add_theme_color_override(
			"font_color",
			Color.WHITE
		)
