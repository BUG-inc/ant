extends Node2D
class_name AntMaster

var _npc_ant = preload("res://entities/npc_ant.tscn")
signal ant_spawn
signal ant_dead

func _ready():
	var queen: Queen = get_node_or_null("Queen")
	for n in get_children():
		if n.has_method("set_pheromones_map"):
			n.set_pheromones_map($PheromoneMap)
		if queen != null and n.has_method("set_queen"):
			n.set_queen($Queen)
	if queen != null:
		$Queen.connect("birthing", self, "_on_queen_birthing")

func spawn_npc_ant(position: Vector2):
	var new_ant = _create_ant()
	new_ant.position = position

func killall():
	for ant in get_tree().get_nodes_in_group("ants"):
		ant.queue_free()
	$PheromoneMap.reset_cells()
	var queen: Queen = get_node_or_null("Queen")
	if queen != null:
		$Queen.reset_resources()

func _create_ant():
	var new_ant = _npc_ant.instance()
	new_ant.set_pheromones_map($PheromoneMap)

	var queen: Queen = get_node_or_null("Queen")
	if queen != null:
		new_ant.set_queen($Queen)
	new_ant.add_to_group("ants")
	add_child(new_ant)
	emit_signal("ant_spawn")
	new_ant.get_node("base_ant").connect("ant_dead", self, "_on_ant_dead")
	return new_ant

func _on_queen_birthing(position: Vector2):
	"""Spawn new ant with special birthing animation."""
	print("Spawning ant in :", position)
	var new_ant = _create_ant()
	new_ant.position = position

func _on_ant_dead():
	emit_signal("ant_dead")
