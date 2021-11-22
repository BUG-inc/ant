extends Node2D


export (float) var change_dir_interval = 1.0

func _ready():
	$base_ant._change_dir_interval = change_dir_interval 

func set_pheromones_map(map: PheromoneMap):
	$base_ant.set_pheromones_map(map)

func set_queen(queen: Queen):
	$base_ant.set_queen(queen)
