extends "res://entities/entity.gd"

class_name BaseAnt

export (int) var speed = 200
export (int) var break_speed = 5
var _dir = Vector2()
var velocity = Vector2()
var pheromone_map: PheromoneMap = null
var queen : Queen = null
var active_sprite = null
export (int) var hit_points = 3
var _death_animation_finished: bool = false

var _bodies_in_interaction_field = []
var _enemy_target: BaseAnt = null
signal ant_dead

enum State {
	WALKING=0
	ATTACKING=1
	DEAD=2
	HURTING=3
	IDLE=4
	BREAKING=5
}
const STATE_NAMES = ["walking", "attacking", "dead", "hurting", "idle", "breaking"]
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
		_current_state = state
		if _current_state == State.ATTACKING or _current_state == State.IDLE or _current_state == State.DEAD:
			velocity = Vector2(0, 0)

func is_dead():
	return _current_state == State.DEAD

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
		# print("Ant was hit")
		hit_points -= 1
		if hit_points == 0:
			die()
		else:
			_dir = direction
			set_state(State.HURTING)
		
func die():
	# print("Ant die!")
	rotation = 0.0 # PI/2.0
	emit_signal("ant_dead")
	set_state(State.DEAD)
	
func is_enemy(body):
	if body.has_method("is_dead"):
		return (
			not body.is_dead() and 
			(
				body.is_in_group("enemy_npc_ants") and (self.is_in_group("npc_ants") or self.is_in_group("player")) or
				(body.is_in_group("npc_ants") or body.is_in_group("player")) and self.is_in_group("enemy_npc_ants")
			)
		)
	return false

func _physics_process(_delta: float) -> void:
	if _current_state == State.DEAD:
		velocity = Vector2(0, 0)
		return
	if _current_state == State.WALKING or _current_state == State.HURTING:
		velocity = move_and_slide(speed * _dir)
	if _current_state == State.BREAKING:
		# this will allow the player to rotate in place while breaking
		velocity = break_speed * _dir
		move_and_slide(velocity)

func _process(_delta: float) -> void:
	_update_animation(_dir)
	# handle automatic state transitions
	if is_equal_approx(velocity.length(), 0) and _current_state == State.WALKING:
			set_state(State.IDLE)
	elif not is_equal_approx(velocity.length(), 0) and _current_state == State.IDLE:
		set_state(State.WALKING)

func _update_animation(dir: Vector2) -> void:
	if _current_state == State.ATTACKING:
		rotation = atan2(_dir.y, _dir.x) + PI/2
	else:
		active_sprite.flip_h = dir.x > 0
		active_sprite.flip_h = dir.x < 0
		if !is_equal_approx(velocity.length(), 0):
			rotation = atan2(velocity.y, velocity.x) + PI/2
		
	if _current_state != State.DEAD or not _death_animation_finished:
		$AnimationPlayer.play(STATE_NAMES[_current_state])
	
func _on_interaction_field_body_entered(body):
	_bodies_in_interaction_field.append(body)
	if is_enemy(body) and _enemy_target == null:
		_enemy_target = body
	_body_entered_interaction_field(body)

func _on_interaction_field_body_exited(body):
	_bodies_in_interaction_field.erase(body)
	if body == _enemy_target:
		_enemy_target = null
		for other_body in _bodies_in_interaction_field:
			if is_enemy(other_body):
				_enemy_target = other_body
				break
	_body_left_interaction_field(body)
	
func _body_entered_interaction_field(_body: Node2D):
	# function for inheriting classes
	pass
	
func _body_left_interaction_field(_body: Node2D):
	# function for inheriting classes
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	#print(anim_name + " " + STATE_NAMES[_current_state])
	if _current_state == State.ATTACKING:
		# print(len(_bodies_in_interaction_field))
		if _enemy_target != null and _enemy_target.has_method("hit"):
			_enemy_target.hit(_dir)
		set_state(State.IDLE)
	if _current_state == State.BREAKING:
		# player ant "breaks" rather than "attacks". This makes controlling the ant less annoying
		if _enemy_target != null and _enemy_target.has_method("hit"):
			_enemy_target.hit(_dir)
		set_state(State.WALKING)
	elif _current_state == State.HURTING:
		set_state(State.WALKING)
	elif _current_state == State.DEAD and anim_name == STATE_NAMES[State.DEAD]:
		_death_animation_finished = true
