extends "res://entities/base_ant.gd"


export (float) var change_dir_interval = 1.0
export (float) var backpacker_change_dir_interval = 0.1
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
	_time_since_change += delta
	if _time_since_change > _change_dir_interval:
		_time_since_change = 0.0
		var new_dir: Vector2 = _change_dir()
		if _limit_direction_flip:
			var angle: float = _dir.angle_to(new_dir)
			_dir = _dir.rotated(max(min(angle, direction_change_limit), -direction_change_limit / 2.0))
		else:
			_dir = new_dir
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

func _weighted_sampling(values: Array) -> int:
	"""
	Randomly sample an index of the given array, where the probability of an
	index i being sampled is p(i)~values[i].
	"""
	var p = randf()
	var normalizer = _sum(values)
	if normalizer == 0.0:
		return randi() % len(values)
	var acc = 0.0
	for i in range(len(values)):
		acc += 1.0 / normalizer *  values[i]
		if p <= acc:
			return i
	# this shouldn't happen
	return len(values) - 1
	
func _sample_random_dir() -> Vector2:
	return Vector2(1.0, 0.0).rotated(_gen.randf_range(0.0, 2.0 * PI)) 

func _change_dir() -> Vector2:
	_gen.randomize()
	if pheromone_map != null:
		_sensed_pheromones = []
		var pheromones = pheromone_map.get_pheromone_levels(global_position, pheromone_range)
		match pheromones:
			[]:
				return _sample_random_dir()
			[var values, var positions]:
				# find pheromones in cone
				var dirs: Array = []
				var in_cone_values = []
				for i in len(values):
					var dir : Vector2 = (positions[i] - global_position).normalized()
					var angle: float = abs(_dir.angle_to(dir))
					if angle <= pheromone_cone_size / 2.0:
						_sensed_pheromones.append(positions[i])
						dirs.append(dir)
						in_cone_values.append(values[i])
				# in case we don't have any values in cone, sample a random direction
				if len(in_cone_values) == 0 or _max(in_cone_values) == 0.0:
					return _sample_random_dir()
				return dirs[_weighted_sampling(in_cone_values)]
	return _sample_random_dir()

func _draw():
	if enable_debug_drawing:
		for point in _sensed_pheromones:
			draw_circle(to_local(point), 2.1, Color(0,1,0,1))

func _on_interaction_field_area_entered(area):
	if area.is_in_group("resources"):
		if _resource_load['number'] == 0:
			_resource_load['number'] = 1
			_resource_load['type'] = area.get_meta('resource_type')		# switch between resource type
			set_animation_style("Miner")
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
				set_change_dir_interval(change_dir_interval)
				_dir = -_dir
				_limit_direction_flip = false

func _on_interaction_field_body_entered(body):
	if body.is_in_group("enemy_npc_ants") and self.is_in_group("npc_ants") or (body.is_in_group("npc_ants") or body.is_in_group("player")) and self.is_in_group("enemy_npc_ants"):
		body.hit(_dir)
