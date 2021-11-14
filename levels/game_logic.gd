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

func _process(delta):
	if _player && Input.is_action_just_pressed("camera_swap"):
		set_player_mode(!_player_mode)

	if !_player_mode:
		_management_loop(delta)
	
		
func _physics_process(_delta: float) -> void:
	if not _player_mode:
		_management_gui()


func _management_gui():
	if $HUD:
		var ants = get_tree().get_nodes_in_group("ants")
		var num_ants = len(ants)
		$HUD/AntNo.text = str(num_ants)


func _management_loop(_delta):
	if Input.is_action_pressed("spawn"):
		var pos = get_local_mouse_position()
		$AntMaster.spawn_npc_ant(pos)

	if Input.is_action_just_pressed("kill"):
		$AntMaster.killall()
		$Level.position = Vector2()
