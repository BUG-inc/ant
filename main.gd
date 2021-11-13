extends Node2D

var _swap_test_level = load("res://levels/test_levels/queen_test.tscn")

func _on_Button_pressed() -> void:
	$menu.queue_free()
	$TileMap.queue_free()
	$hud_ants.queue_free()
	add_child(_swap_test_level.instance())
