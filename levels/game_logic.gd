extends Node2D

export var _player_mode = true
onready var _player = $AntMaster/player
onready var _camera = $camera


func set_player_mode(val: bool):
	if _player:
		_player.get_node("base_ant").set_control(val)
		_player_mode = val
		if _camera:
			_camera.set_active(!val, _player.position + _player.get_node("base_ant").position)


func _ready():
	set_player_mode(true)
	_update_ant_no()

func _process(delta):
	if Input.is_action_just_pressed("pause_menu") && !get_tree().paused:
		show_menu()
	elif Input.is_action_just_pressed("pause_menu") && get_tree().paused:
		hide_menu()
	else:
		if _player && Input.is_action_just_pressed("camera_swap"):
			set_player_mode(!_player_mode)

		if !_player_mode:
			_management_loop(delta)
	

func show_menu():
	"""Display the pause menu."""	
	$pause_menu.get_child(0).show()  # https://godotengine.org/qa/55202/how-to-hide-a-canvas-layer-node
	get_tree().paused = true

func hide_menu():
	"""Hide the pause menu."""	
	$pause_menu.get_child(0).hide()  # https://godotengine.org/qa/55202/how-to-hide-a-canvas-layer-node
	get_tree().paused = false

		
func _update_ant_no():
	var ants = get_tree().get_nodes_in_group("ants")
	var num_ants = len(ants)
	$HUD/AntNo.text = str(num_ants)


func _management_loop(_delta):
	if OS.is_debug_build() && Input.is_action_pressed("spawn"):
		var pos = get_local_mouse_position()
		$AntMaster.spawn_npc_ant(pos)

	if OS.is_debug_build() && Input.is_action_just_pressed("kill"):
		$AntMaster.killall()
		$Level.position = Vector2()


func _on_Queen_resource_update(type: String, number: int):
	$HUD/ResourceNo.text = str(number)


func _on_player_dig_hole(position):
	$Level/Foreground.dig_hole(position)


func _on_main_menu_Button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene("res://main.tscn")


func _on_AntMaster_ant_spawn() -> void:
	_update_ant_no()


func _on_AntMaster_ant_dead() -> void:
	_update_ant_no()
