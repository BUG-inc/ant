extends "res://entities/entity.gd"

class_name BaseAnt

export (int) var speed = 200
var _dir = Vector2()
var velocity = Vector2()
var pheromone_map: PheromoneMap = null
var queen : Queen = null
var active_sprite = null
export (int) var hit_points = 3

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
	# initialize active_sprite with the one that is set visible in the scene
	for sprite in [$Default, $Miner, $Enemy, $Chief]:
		if sprite.is_visible():
			if active_sprite != null:
				active_sprite.hide()
				print("WARNING: Multiple sprites innitially visible for ant node" + self.name)
			active_sprite = sprite

func set_state(state: int):
	if state != _current_state:
		print("Setting state " + STATE_NAMES[state])
		_current_state = state
		if _current_state == State.ATTACKING or _current_state == State.IDLE or _current_state == State.DEAD:
			_dir = Vector2(0, 0)

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
	if _current_state != State.HURTING and _current_state != State.DEAD:
		print("Ant was hit")
		hit_points -= 1
		if hit_points == 0:
			die()
		else:
			_dir = direction
			set_state(State.HURTING)
		
func die():
	set_state(State.DEAD)

func _physics_process(_delta: float) -> void:
	if _current_state == State.DEAD:
		velocity = Vector2(0, 0)
		return
	velocity = move_and_slide(speed * _dir)

func _process(_delta: float) -> void:
	_update_animation(_dir)
	$AnimationPlayer.play(STATE_NAMES[_current_state])

func _update_animation(dir: Vector2) -> void:
	if dir.x > 0:
		active_sprite.flip_h = false

	if dir.x < 0:
		active_sprite.flip_h = true

	if !is_equal_approx(velocity.length(), 0):
		rotation = atan2(velocity.y, velocity.x) + PI/2
	
	if is_equal_approx(velocity.length(), 0):
		if _current_state == State.WALKING:
			set_state(State.IDLE)
	else:
		set_state(State.WALKING)
