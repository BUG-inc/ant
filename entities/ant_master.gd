extends Node2D
class_name AntMaster

var _npc_ant = preload("res://entities/npc_ant.tscn")


func _ready():
	for n in get_children():
		if n.has_method("set_pheromones_map"):
			n.set_pheromones_map($PheromoneMap)

func spawn_npc_ant(position: Vector2):
	var new_ant = _npc_ant.instance()
	new_ant.set_pheromones_map($PheromoneMap) 
	new_ant.position = position
	new_ant.add_to_group("ants")
	# TODO set pheromones map
	add_child(new_ant)
	if _can_play_sound():
			new_ant.get_node("AudioStreamPlayer").playing = true

func killall():
	for ant in get_tree().get_nodes_in_group("ants"):
		ant.queue_free()

	$PheromoneMap.reset_cells()

func _can_play_sound() -> bool:
	var ants = get_tree().get_nodes_in_group("ants")
	for ant in ants:
		if ant.get_node("AudioStreamPlayer").playing:
			return false
	return true
