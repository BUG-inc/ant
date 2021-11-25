extends "res://entities/base_ant.gd"

export (Vector2) var tool_point = Vector2(40.0, 0.0)
signal dig_hole_signal(position)

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

	if OS.is_debug_build() && Input.is_action_just_pressed("pheromone_toggle_key"):
		_toggle_pheromone_mode()

	if Input.is_action_pressed("pheromone_action_key"):
		if _is_laying:
			pheromone_map.add_pheromone(global_position)
		elif _is_removing:
			pheromone_map.remove_pheromone(global_position)

func _handle_action():
	if Input.is_action_pressed("dig_hole"):
		emit_signal("dig_hole_signal", to_global(tool_point))
		set_state(State.BREAKING)
		if len(_bodies_in_interaction_field) > 0:
			for body in _bodies_in_interaction_field:
				if _bodies_in_interaction_field[0].has_method("hit"):
					_bodies_in_interaction_field[0].hit(_dir)
					break

func _toggle_pheromone_mode():
	var temp = _is_laying
	_is_laying = _is_removing
	_is_removing = temp
	if _is_laying:
		$player_hud/GridContainer/pheromone_val.text = "Laying"
	else:
		$player_hud/GridContainer/pheromone_val.text = "Removing"

		
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
