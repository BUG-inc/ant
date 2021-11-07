extends CanvasLayer

var _ant_scene = load("res://entities/ant.tscn")

func _process(_delta):
	if Input.is_action_pressed("spawn"):
		var pos = get_viewport().get_mouse_position()
		var new_ant = _ant_scene.instance()
		new_ant.position = pos
		new_ant.add_to_group("ants")
		add_child(new_ant)

	if Input.is_action_just_pressed("kill"):
		var ants = get_tree().get_nodes_in_group("ants")
		for ant in ants:
			ant.queue_free()
		
