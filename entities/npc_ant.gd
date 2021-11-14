extends Node2D


export (float) var change_dir_interval = 0.1

func set_pheromones_map(map: PheromoneMap):
	var base_ant = get_node_or_null("base_ant")
	if base_ant:
		base_ant.set_pheromones_map(map)

