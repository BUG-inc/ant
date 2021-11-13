extends Node2D


export (float) var change_dir_interval setget update_dir_interval


func update_dir_interval(val: float):
	if $base_ant != null:
		$base_ant.change_dir(val)
