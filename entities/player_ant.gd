extends "res://entities/base_ant.gd"

var _is_control = true
var _is_laying = true


func _ready():
	print("player ant ready")

func set_control(val: bool):
	_is_control = val
	$Camera2D.current = true
	# if !val:
	# 	$player_hud.hide()
	# else:
	# 	$player_hud.show()


func _physics_process(_delta: float) -> void:
	if _is_control:
		_handle_movement()
		_handle_pheromone()


func _handle_pheromone():
	"""
		Player ant can lay down pheromone or remove pheromone from the map.

		The player will have to switch between modes.
	"""
	if pheromone_map == null:
		return

	if _is_laying and Input.is_action_pressed("pheromone_action_key"):
		pheromone_map.add_pheromone(global_position)

		
func _handle_movement():
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
