extends "res://entities/base_ant.gd"


export (float) var change_dir_interval = 1.0 setget change_dir
var _gen = RandomNumberGenerator.new()
var _time_since_change := 0.0
var pheromone_map: PheromoneMap = null
export (int) var pheromone_range = 2

func set_pheromones_map(map: PheromoneMap):
	pheromone_map = map

func _ready():
	_dir = _change_dir()

func change_dir(val: float):
	change_dir_interval = val
	
func _physics_process(delta: float) -> void:
	_time_since_change += delta

	if _time_since_change > change_dir_interval:
		_time_since_change = 0.0
		_dir = _change_dir()

	velocity = move_and_slide(speed * _dir)
	
func _sum(values: Array) -> float:
	var acc: float = 0.0
	for v in values:
		acc += v
	return acc

func _weighted_sampling(values: Array) -> int:
	"""
	Randomly sample an index of the given array, where the probability of an
	index i being sampled is ~values[i].
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

func _change_dir() -> float:
	_gen.randomize()
	var dir = Vector2(0, 0)
	if pheromone_map != null:
		var pheromones = pheromone_map.get_pheromone_levels(global_position, pheromone_range)
		if len(pheromones) > 0:
			var index = _weighted_sampling(pheromones[0])
			dir = pheromones[1][index] - global_position
	if dir.length() == 0.0:
		dir = Vector2(_gen.randf_range(-1, 1), _gen.randf_range(-1, 1))  # bias towards goal
	dir = dir.normalized()
	return dir
