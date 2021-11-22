extends Node2D

var _swap_test_level = preload("res://levels/production_levels/intro_level.tscn")

func _on_Button_pressed() -> void:
	$menu.queue_free()
	$menu_level.queue_free()
	$hud_ants.queue_free()
	add_child(_swap_test_level.instance())
