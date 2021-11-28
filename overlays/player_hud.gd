extends CanvasLayer

func _ready():
	$Help/Lay.text = _action_name_to_key_name("pheromone_laying")
	$Help/Remove.text = _action_name_to_key_name("pheromone_removing")
	$Help/ToggleMap.text = _action_name_to_key_name("camera_swap")
	$Help/ToggleHelp.text = _action_name_to_key_name("toggle_help")
	$Help/Pause.text = _action_name_to_key_name("pause_menu")
	$Help/Break.text = _action_name_to_key_name("dig_hole")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_help"):
		if $Help.is_visible_in_tree():
			$Help.hide()
		else:
			$Help.show()

func _on_base_ant_adding_pheromone() -> void:
	$GridContainer/Removing.hide()
	$GridContainer/Laying.show()

func _on_base_ant_no_pheromone() -> void:
	$GridContainer/Laying.hide()
	$GridContainer/Removing.hide()

func _on_base_ant_removing_pheromone() -> void:
	$GridContainer/Laying.hide()
	$GridContainer/Removing.show()

func _action_name_to_key_name(action_name: String) -> String:
	return OS.get_scancode_string(InputMap.get_action_list(action_name)[0].physical_scancode)
