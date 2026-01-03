## Trinket selection screen after winning a run
extends Control

# Trinket panel references
var trinket_panels: Array[Panel] = []
var offered_trinkets: Array[Trinket] = []


func _ready() -> void:
	# Get trinket panel references
	var container := $VBox/TrinketContainer
	trinket_panels = [
		container.get_node("Trinket1") as Panel,
		container.get_node("Trinket2") as Panel,
		container.get_node("Trinket3") as Panel
	]

	# Get current trinket IDs to exclude
	var exclude_ids: Array = []
	if GameManager:
		for trinket in GameManager.active_trinkets:
			if trinket:
				exclude_ids.append(trinket.id)

	# Get legendary availability
	var include_legendary := false
	if GameManager and GameManager.meta_progress:
		include_legendary = GameManager.meta_progress.has_upgrade("legendary_trinkets")

	# Generate 3 random trinkets
	offered_trinkets = TrinketManager.get_random_trinkets(3, exclude_ids, include_legendary)

	# Populate UI
	for i in range(mini(offered_trinkets.size(), 3)):
		_populate_trinket_panel(i, offered_trinkets[i])


func _populate_trinket_panel(index: int, trinket: Trinket) -> void:
	if index >= trinket_panels.size():
		return

	var panel := trinket_panels[index]
	var vbox := panel.get_node("VBox")

	# Set rarity
	var rarity_label := vbox.get_node("Rarity") as Label
	rarity_label.text = trinket.get_rarity_name().to_upper()
	rarity_label.modulate = trinket.get_rarity_color()

	# Set name
	var name_label := vbox.get_node("Name") as Label
	name_label.text = trinket.name

	# Set description
	var desc_label := vbox.get_node("Description") as Label
	desc_label.text = trinket.description

	# Set flavor text
	var flavor_label := vbox.get_node("Flavor") as Label
	flavor_label.text = "\"%s\"" % trinket.flavor_text

	# Connect button
	var button := vbox.get_node("SelectButton") as Button
	button.pressed.connect(_on_trinket_selected.bind(index))


func _on_trinket_selected(index: int) -> void:
	if index >= offered_trinkets.size():
		return

	var selected_trinket := offered_trinkets[index]

	# Add to active trinkets
	if GameManager:
		GameManager.add_trinket(selected_trinket)

	# Unlock permanently
	if GameManager and GameManager.meta_progress:
		GameManager.meta_progress.unlock_trinket(selected_trinket.id)
		SaveManager.save_meta_progress(GameManager.meta_progress)

	# Start next run with increased difficulty
	if GameManager and GameManager.current_run:
		var new_difficulty := GameManager.current_run.difficulty + 1
		GameManager.start_new_run(new_difficulty)
		get_tree().change_scene_to_file("res://scenes/main/game.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
