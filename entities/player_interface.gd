extends Node2D

signal dig_hole(position)

func set_pheromones_map(map: PheromoneMap):
	$base_ant.set_pheromones_map(map)


func _on_base_ant_dig_hole_signal(position):
	print("Emitting dig signal")
	emit_signal("dig_hole", position)
