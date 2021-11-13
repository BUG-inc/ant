extends "res://entities/base_ant.gd"

var _is_control = true


func set_control(val: bool):
	_is_control = val
	$Camera2D.current = true


func _physics_process(_delta: float) -> void:
	if _is_control:
		_dir = Vector2()
		if Input.is_action_pressed("ui_left"):
			_dir.x -= 1
		if Input.is_action_pressed("ui_right"):
			_dir.x += 1
		if Input.is_action_pressed("ui_up"):
			_dir.y -= 1
		if Input.is_action_pressed("ui_down"):
			_dir.y += 1

		_dir = _dir.normalized()
		

		velocity = move_and_slide(speed * _dir)
	