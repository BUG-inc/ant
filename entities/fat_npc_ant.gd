extends Node2D


export (float) var change_dir_interval setget update_dir_interval

func update_dir_interval(val: float):
	var base_ant = get_node_or_null("base_ant")
	if base_ant:
		base_ant.change_dir(val)

func set_pheromones_map(map: PheromoneMap):
	var base_ant = get_node_or_null("base_ant")
	if base_ant:
		base_ant.set_pheromones_map(map)
