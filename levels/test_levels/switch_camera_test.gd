extends Node2D

var _player_mode = true
var _fat_npc_ant = load("res://entities/fat_npc_ant.tscn")

func set_player_mode(val: bool):
	$player/base_ant.set_control(val)
	$Level.use_level_camera(!val, $player.position + $player/base_ant.position)
	_player_mode = val


func _ready():
	set_player_mode(true)

func _process(delta):
	if Input.is_action_just_pressed("camera_swap"):
		set_player_mode(!_player_mode)

	if !_player_mode:
		_management_loop(delta)
	
		
func _physics_process(_delta: float) -> void:
	if not _player_mode:
		_management_gui()


func _management_gui():
	var ants = get_tree().get_nodes_in_group("ants")
	var num_ants = len(ants)
	$HUD/AntNo.text = str(num_ants)


func _management_loop(_delta):
	if Input.is_action_pressed("spawn"):
		var pos = get_local_mouse_position()
		$Level/AntMaster.spawn_npc_ant(pos)

	if Input.is_action_just_pressed("kill"):
		$Level/AntMaster.killall()
		$Level.position = Vector2()
