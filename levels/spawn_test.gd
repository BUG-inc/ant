extends Node2D

var _fat_npc_ant = load("res://entities/fat_npc_ant.tscn")
var _npc_ant = load("res://entities/npc_ant.tscn")
var tick = 0

func _process(_delta):
	if Input.is_action_pressed("spawn"):
		var pos = get_viewport().get_mouse_position()
		var new_ant

		if tick % 2 == 0:
			new_ant = _npc_ant.instance()
		else:
			new_ant = _fat_npc_ant.instance()
		
		tick += 1
		var level_pos = $Level.get_global_transform()
		new_ant.position = pos - level_pos.get_origin()
		new_ant.add_to_group("ants")
		if _can_play_sound():
			new_ant.get_node("AudioStreamPlayer").playing = true

		$Level.add_child(new_ant)

	if Input.is_action_just_pressed("kill"):
		var ants = get_tree().get_nodes_in_group("ants")
		for ant in ants:
			ant.queue_free()

		$Level.position = Vector2()
		

func _physics_process(_delta: float) -> void:
	var ants = get_tree().get_nodes_in_group("ants")
	var num_ants = len(ants)
	$HUD/AntNo.text = str(num_ants)


func _can_play_sound() -> bool:
	var ants = get_tree().get_nodes_in_group("ants")
	for ant in ants:
		if ant.get_node("AudioStreamPlayer").playing:
			return false

	return true
