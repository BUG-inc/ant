extends Node2D

var tick = 0

func _process(_delta):
	if Input.is_action_pressed("spawn"):
		var pos = get_local_mouse_position()
		$Level/AntMaster.spawn_npc_ant(pos)

	if Input.is_action_just_pressed("kill"):
		$Level/AntMaster.killall()

func _physics_process(_delta: float) -> void:
	var ants = get_tree().get_nodes_in_group("ants")
	var num_ants = len(ants)
	$HUD/AntNo.text = str(num_ants)
