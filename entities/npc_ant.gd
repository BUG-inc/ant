extends "res://entities/base_ant.gd"


export (float) var change_dir_interval = 1.0
var _gen = RandomNumberGenerator.new()
var _time_since_change := 0.0


func _ready():
	_dir = _change_dir()


func _physics_process(delta: float) -> void:
	_time_since_change += delta

	if _time_since_change > change_dir_interval:
		_time_since_change = 0.0
		_dir = _change_dir()

	velocity = move_and_slide(speed * _dir)
	

func _change_dir() -> float:
	_gen.randomize()
	var dir = Vector2(_gen.randf_range(-1, 1), _gen.randf_range(-1, 1))  # bias towards goal
	dir = dir.normalized()
	return dir
