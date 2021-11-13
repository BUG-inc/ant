extends Node2D

export var scroll_speed = 100
export var min_x = 0
export var min_y = 0
export var max_x = 100000
export var max_y = 100000
var _is_active = true

func set_active(val: bool):
	_is_active = val

func _physics_process(delta: float) -> void:
	if _is_active:
		var scroll_dir = Vector2()

		if Input.is_action_pressed("ui_down"):
			scroll_dir.y += 1

		if Input.is_action_pressed("ui_up"):
			scroll_dir.y -= 1

		if Input.is_action_pressed("ui_right"):
			scroll_dir.x += 1

		if Input.is_action_pressed("ui_left"):
			scroll_dir.x -= 1
		
		scroll_dir = scroll_dir.normalized()
		position.x += scroll_speed * scroll_dir.x * delta
		position.y += scroll_speed * scroll_dir.y * delta

		position.x = clamp(position.x, min_x, max_x)
		position.y = clamp(position.y, min_y, max_y)
