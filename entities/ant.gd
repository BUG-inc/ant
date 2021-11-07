extends "res://entities/entity.gd"


export (int) var speed = 200
export (float) var change_dir_interval = 1.0
var _gen = RandomNumberGenerator.new()
var _dir = Vector2()
var _time_since_change := 0.0
var velocity = Vector2()


func _process(_delta: float) -> void:
	_update_animation(_dir)


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


func _update_animation(dir: Vector2) -> void:
	if dir.x > 0:
		$AnimatedSprite.animation = "right"

	if dir.x < 0:
		$AnimatedSprite.animation = "left"
	
	$AnimatedSprite.playing = true
