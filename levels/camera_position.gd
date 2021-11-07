extends Node2D

export var scroll_speed = 100

func _physics_process(delta: float) -> void:
	var scroll_dir = Vector2()

	if Input.is_action_pressed("ui_down"):
		scroll_dir.y -= 1

	if Input.is_action_pressed("ui_up"):
		scroll_dir.y += 1

	if Input.is_action_pressed("ui_right"):
		scroll_dir.x -= 1

	if Input.is_action_pressed("ui_left"):
		scroll_dir.x += 1
	
	scroll_dir = scroll_dir.normalized()
	position.x += scroll_speed * scroll_dir.x * delta
	position.y += scroll_speed * scroll_dir.y * delta
