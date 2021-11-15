extends "res://entities/entity.gd"

export (int) var speed = 200
var _dir = Vector2()
var velocity = Vector2()
var pheromone_map: PheromoneMap = null
var queen : Queen = null
onready var active_anim = $Default
var _hit_dir:= Vector2()
export (int) var hit_points = 3
export (Curve) var hit_curve
export (float, 0.1, 2.0) var hit_duration = 0.5
export (float, 0.0, 100) var hit_speed = 20
var _hit_time: float = hit_duration

func _ready():
	if hit_curve == null:
		hit_curve = Curve.instance()
		hit_curve.add_point(Vector2(0, 1.0))
		hit_curve.add_point(Vector2(1.0, 0.0))

func set_pheromones_map(map: PheromoneMap):
	pheromone_map = map
	
func set_queen(in_queen: Queen):
	queen = in_queen

func change_animation_style(type: String):
	active_anim.hide()
	active_anim.playing = false
	active_anim = get_node_or_null(type)
	if active_anim == null:
		active_anim = $Default
		print("WARNING: Attempted to set invalid animation style " + type)
	active_anim.playing = true
	active_anim.show()
	
func hit(direction: Vector2):
	print("Ant was hit")
	if _hit_time >= hit_duration:
		_hit_time = 0.0
		_hit_dir = direction
		hit_points -= 1
		if hit_points == 0:
			die()
		
func die():
	# TODO issue death animation
	queue_free()

func _physics_process(delta: float) -> void:
	if _hit_time < hit_duration:
		# TODO this doesn't really work
		velocity = move_and_slide(hit_speed * 2.0 * (hit_curve.interpolate(_hit_time / hit_duration) - 0.5) * _hit_dir)
		_hit_time += delta
	else:
		velocity = move_and_slide(speed * _dir)


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
