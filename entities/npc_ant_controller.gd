extends "res://entities/base_ant.gd"

export (float) var change_dir_interval = 1.0
export (float) var backpacker_change_dir_interval = 0.1 * change_dir_interval
export (int) var pheromone_range = 2
export (float) var pheromone_cone_size = 180.0 / 180.0 * PI  # total angle of the cone in radians
export (float) var direction_change_limit = 45.0 / 180.0 * PI
export (bool) var enable_debug_drawing = false

var _change_dir_interval: float = change_dir_interval
var _gen = RandomNumberGenerator.new()
var _time_since_change := 0.0
var _sensed_pheromones: Array = []
var _resource_load: Dictionary = {'type': null, 'number': 0}
var _limit_direction_flip: bool = false

func _ready():
	_dir = _change_dir()
	
func set_change_dir_interval(val: float):
	_change_dir_interval = val
	
func _physics_process(delta: float) -> void:
	if _current_state in [State.WALKING, State.RESOURCE_WALKING]:
		_time_since_change += delta
		if _time_since_change > _change_dir_interval:
			_time_since_change = 0.0
			var new_dir: Vector2 = _change_dir()
			if _limit_direction_flip:
				var angle: float = _dir.angle_to(new_dir)
				_dir = _dir.rotated(max(min(angle, direction_change_limit), -direction_change_limit / 2.0))
			else:
				_dir = new_dir
	elif _current_state == State.IDLE:
		_time_since_change = 0.0
		_dir = _change_dir()
		set_state(State.WALKING)
	elif _current_state == State.ATTACKING:
		var relative_pos: Vector2 = _enemy_target.get_global_position() - get_global_position()
		_dir = relative_pos.normalized()
	if enable_debug_drawing:
		update()
	
func _sum(values: Array) -> float:
	var acc: float = 0.0
	for v in values:
		acc += v
	return acc

func _max(values: Array) -> float:
	var max_val: float = -INF
	for v in values:
		max_val = max(v, max_val)
	return max_val

func _sample_dir(visible_pheromones: Dictionary) -> Vector2:
	"""
		Samples a direction for the ant to follow.

		If the ant is carrying a resource, pick the direction that points towards the queen. Otherwise, randomly choose
		a pheromone direction, and draw a direction from a normal centred on the pheromone dir.
	"""
	var chosen_dir = Vector2()

	if _current_state != State.RESOURCE_WALKING:
		var chosen_dir_idx = _sample_index(visible_pheromones['values'])
		chosen_dir = visible_pheromones['directions'][chosen_dir_idx]
	else:
		# we're carrying resources, get the pheromone that's closer to the queen direction
		var queen_dir = _get_queen_dir()
		var angle = _get_angle(queen_dir, chosen_dir)
		for dir in visible_pheromones['directions']:
			var test_angle = _get_angle(queen_dir, dir)
			if abs(test_angle) < abs(angle):
				angle = test_angle
				chosen_dir = dir
			
	return chosen_dir

func _get_angle(v1: Vector2, v2: Vector2) -> float:
	"""Return the angle between two vectors."""
	var diff = v1 - v2
	return atan2(diff.y, diff.x)
	
func _sample_index(values: Array) -> int:
	"""Randomly sample an index of the given array, where the probability of an
	index i being sampled is p(i)~values[i]."""
	var p = randf()
	var normalizer = _sum(values)
	var chosen_dir_idx = len(values) - 1

	if normalizer == 0.0:
		chosen_dir_idx = randi() % len(values)
	var acc = 0.0
	for i in range(len(values)):
		acc += 1.0 / normalizer *  values[i]
		if p <= acc:
			chosen_dir_idx = i
			break
	
	return chosen_dir_idx

func _sample_random_dir(bias = null) -> Vector2:
	var random_angle
	if bias != null:
		random_angle = _gen.randf_range(bias - PI/2, bias + PI/2)
	else:
		random_angle = _gen.randf_range(0.0, 2.0*PI)
	return Vector2(1.0, 0.0).rotated(random_angle) 

func _change_dir() -> Vector2:
	_gen.randomize()
	if pheromone_map != null:
		return _follow_pheromone()
	return _sample_random_dir()

func _follow_pheromone() -> Vector2:
	_sensed_pheromones = []
	var pheromones = pheromone_map.get_pheromone_levels(global_position, pheromone_range)
	match pheromones:
		[var values, var positions]:
			var visible_pheromones = get_pheromones_in_cone(values, positions)
			if len(visible_pheromones['values']) != 0 and _max(visible_pheromones['values']) != 0.0:
				return _sample_dir(visible_pheromones)

	if _current_state != State.RESOURCE_WALKING:
		return _sample_random_dir()
	
	var queen_dir = _get_queen_dir()
	return _sample_random_dir(atan2(queen_dir.y, queen_dir.x))
	

func _get_queen_dir() -> Vector2:
	return (globals.queen_pos - global_position).normalized()

func get_pheromones_in_cone(values: Array, positions: Array) -> Dictionary:
	"""Return a dictionary with the pheromone values and corresponding direction."""
	var dirs: Array = []
	var in_cone_values = []
	for i in len(values):
		var dist: float = (positions[i] - global_position).length()
		var dir : Vector2 = (positions[i] - global_position).normalized()
		var angle: float = abs(_dir.angle_to(dir))
		if angle <= pheromone_cone_size / 2.0 and dist > 20:
			_sensed_pheromones.append(positions[i])
			dirs.append(dir)
			in_cone_values.append(values[i])
	return {
		'directions': dirs, 
		'values': in_cone_values
	}

func _draw():
	if enable_debug_drawing:
		for point in _sensed_pheromones:
			draw_circle(to_local(point), 2.1, Color(0,1,0,1))

func _on_interaction_field_area_entered(area):
	if area.is_in_group("resources"):
		if _resource_load['number'] == 0:
			var collected = area.get_meta('resource_node').collect()
			if collected > 0:  # can be 0 if, e.g., the resource was depleted
				_resource_load['number'] += collected
				_resource_load['type'] = area.get_meta('resource_type')		# switch between resource type
				set_animation_style("Miner")
				_current_state = State.RESOURCE_WALKING
				set_change_dir_interval(backpacker_change_dir_interval)
				_dir = -_dir
				_limit_direction_flip = true
	elif area.is_in_group("queen"):
		if _resource_load['number'] > 0:
			if queen != null:
				queen.deliver_resource(_resource_load["type"], _resource_load["number"])
				_resource_load["type"] = ""
				_resource_load["number"] = 0
				set_animation_style("Default")
				_current_state = State.WALKING
				set_change_dir_interval(change_dir_interval)
				_dir = -_dir
				_limit_direction_flip = false

func _body_entered_interaction_field(body):
	if _current_state != State.WALKING and _current_state != State.IDLE:
		return
	if is_enemy(body) and _current_state != State.ATTACKING and _resource_load["number"] == 0:
		set_state(State.ATTACKING)
		
func _body_left_interaction_field(_body):
	if _current_state == State.ATTACKING and _enemy_target == null:
		set_state(State.WALKING)
