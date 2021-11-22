extends Node2D
class_name AntMaster

var _npc_ant = preload("res://entities/npc_ant.tscn")


func _ready():
	var queen: Queen = get_node_or_null("Queen")
	for n in get_children():
		if n.has_method("set_pheromones_map"):
			n.set_pheromones_map($PheromoneMap)
		if queen != null and n.has_method("set_queen"):
			n.set_queen($Queen)

func spawn_npc_ant(position: Vector2):
	var new_ant = _npc_ant.instance()
	new_ant.set_pheromones_map($PheromoneMap)

	var queen: Queen = get_node_or_null("Queen")
	if queen != null:
		new_ant.set_queen($Queen)

	new_ant.position = position
	new_ant.add_to_group("ants")
	add_child(new_ant)

	if _can_play_sound():
			new_ant.get_node("AudioStreamPlayer").playing = true

func killall():
	for ant in get_tree().get_nodes_in_group("ants"):
		ant.queue_free()
	$PheromoneMap.reset_cells()
	var queen: Queen = get_node_or_null("Queen")
	if queen != null:
		$Queen.reset_resources()

func _can_play_sound() -> bool:
	var ants = get_tree().get_nodes_in_group("ants")
	for ant in ants:
		if ant.get_node("AudioStreamPlayer").playing:
			return false
	return true
