extends "res://entities/entity.gd"

export (int) var speed = 200
var _dir = Vector2()
var velocity = Vector2()
var pheromone_map: PheromoneMap = null
var queen : Queen = null
onready var active_sprite = null
var _hit_dir:= Vector2()
export (int) var hit_points = 3
export (Curve) var hit_curve
export (float, 0.1, 2.0) var hit_duration = 0.5
export (float, 0.0, 100) var hit_speed = 20
var _hit_time: float = hit_duration

enum State {
	WALKING=0
	ATTACKING=1
	DEAD=2
	HURTING=3
	IDLE=4
}
const STATE_NAMES = ["walking", "attacking", "dead", "hurting", "idle"]
var _current_state: int = State.IDLE

func _ready():
	if hit_curve == null:
		hit_curve = Curve.instance()
		hit_curve.add_point(Vector2(0, 1.0))
		hit_curve.add_point(Vector2(1.0, 0.0))
	# initialize active_sprite with the one that is set visible in the scene
	for sprite in [$Default, $Miner, $Enemy, $Chief]:
		if sprite.is_visible():
			if active_sprite != null:
				print("WARNING: Multiple sprites innitially visible for ant")
			active_sprite = sprite

func set_state(state: int):
	_current_state = state
	$AnimationPlayer.play(STATE_NAMES[_current_state])

func set_pheromones_map(map: PheromoneMap):
	pheromone_map = map
	
func set_queen(in_queen: Queen):
	queen = in_queen

func set_animation_style(type: String):
	active_sprite.hide()
	active_sprite = get_node_or_null(type)
	if active_sprite == null:
		active_sprite = $Default
		print("WARNING: Attempted to set invalid animation style " + type)
	active_sprite.show()
	
func hit(direction: Vector2):
	print("Ant was hit")
	if _hit_time >= hit_duration:
		_hit_time = 0.0
		_hit_dir = direction
		hit_points -= 1
		if hit_points == 0:
			die()
		
func die():
	set_state(State.DEAD)
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
		active_sprite.flip_h = false

	if dir.x < 0:
		active_sprite.flip_h = true

	if !is_equal_approx(velocity.length(), 0):
		rotation = atan2(velocity.y, velocity.x) + PI/2
	
	if is_equal_approx(velocity.length(), 0):
		set_state(State.IDLE)
	else:
		set_state(State.WALKING)
