extends Node2D
class_name AntMaster

var _fat_npc_ant = preload("res://entities/fat_npc_ant.tscn")
var _npc_ant = preload("res://entities/npc_ant.tscn")

func spawn_npc_ant(position: Vector2):
	var new_ant = _fat_npc_ant.instance()
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
