extends "res://entities/entity.gd"

export (int) var speed = 200
var _dir = Vector2()
var velocity = Vector2()
var pheromone_map: PheromoneMap = null
onready var active_anim = $Default

func set_pheromones_map(map: PheromoneMap):
	pheromone_map = map

func _process(_delta: float) -> void:
	_update_animation(_dir)

func _update_animation(dir: Vector2) -> void:
	if dir.x > 0:
		active_anim.flip_h = false

	if dir.x < 0:
		active_anim.flip_h = true

	if !is_equal_approx(velocity.length(), 0):
		rotation = atan2(velocity.y, velocity.x) + PI/2
	
	if is_equal_approx(velocity.length(), 0):
		active_anim.animation = "idle"
	else:
		active_anim.animation = "walking"

	active_anim.playing = true
