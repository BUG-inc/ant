extends "res://entities/base_ant.gd"

export (Vector2) var tool_point = Vector2(40.0, 0.0)
signal dig_hole_signal(position)
signal adding_pheromone
signal removing_pheromone
signal no_pheromone

var _is_control = true
var _is_laying = true
var _is_removing = false

func _ready():
	print("player ant ready")
	set_animation_style("Chief")
	set_state(State.IDLE)

func set_control(val: bool):
	_is_control = val
	$Camera2D.current = true
	if !val:
		$player_hud/GridContainer.hide()
	else:
		$player_hud/GridContainer.show()

func _physics_process(_delta: float) -> void:
	if _is_control:
		_handle_movement()
		_handle_pheromone()
		_handle_action()

func _handle_pheromone():
	"""
		Player ant can lay down pheromone or remove pheromone from the map.

		The player will have to switch between modes.
	"""
	if pheromone_map == null:
		return

	if Input.is_action_pressed("pheromone_laying"):
		pheromone_map.add_pheromone(global_position)
		emit_signal("adding_pheromone")
	elif Input.is_action_pressed("pheromone_removing"):
		pheromone_map.remove_pheromone(global_position)
		emit_signal("removing_pheromone")
	else:
		emit_signal("no_pheromone")


func _handle_action():
	if Input.is_action_pressed("dig_hole"):
		emit_signal("dig_hole_signal", to_global(tool_point))
		set_state(State.BREAKING)

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
	if _dir.length() > 0.0:
		set_state(State.WALKING)
