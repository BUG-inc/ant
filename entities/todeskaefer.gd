extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var _dir = Vector2(0, 0)
export (float) var dir_change_interval = 2.0
export (float) var speed = 30
export (float) var min_speed = 20

enum State {
	WALKING=0
	BITING=1
	HUNTING=2  # approaching an ant in the sensing area
	DEAD=3
}
const STATE_TO_ANIMATION_NAMES = ["walking", "attacking", "walking", "dead"]

var _time_since_dir_change = 0.0
var _current_state: int = State.WALKING
var _gen = RandomNumberGenerator.new()
var _ant_in_biting_area: BaseAnt = null
var _ant_in_sensing_area: BaseAnt = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func set_state(new_state: int):
	_current_state = new_state

func is_eadible(body) -> bool:
	"""
	Return true if the Todeskaefer would eat/kill the given body.
	"""
	return body.is_in_group("player") or body.is_in_group("npc_ants") or body.is_in_group("enemy_npc_ants")

func set_orientation(angle: float):
	"""
	Set the walking orientation of the Kaefer.
	"""
	_time_since_dir_change = 0.0
	_dir = Vector2(1, 0).rotated(angle)
	rotation = atan2(_dir.y, _dir.x) + PI / 2

func _physics_process(delta):
	_time_since_dir_change += delta
	if _time_since_dir_change >= dir_change_interval:
		set_orientation(2.0 * PI * _gen.randf())
	var velocity: Vector2 = move_and_slide(speed * _dir)
	# if the beetle is stuck force a direction change
	if _current_state == State.WALKING and velocity.length() < min_speed:
		_time_since_dir_change = dir_change_interval

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$AnimationPlayer.play(STATE_TO_ANIMATION_NAMES[_current_state])

func _on_BiteArea_body_entered(body):
	#print("body in biting area: " + str(body.get_groups()))
	if is_eadible(body):
		if not body.has_method("is_dead"):
			print("ERROR: Body that belongs to ant group does not have is_dead function!")
			return
		if _ant_in_biting_area == null and not body.is_dead():
			_ant_in_biting_area = body
			set_state(State.BITING)

func _on_BiteArea_body_exited(body):
	#print("body left area: " + str(body.get_groups()))
	if body == _ant_in_biting_area:
		_ant_in_biting_area = null
		set_state(State.WALKING)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == STATE_TO_ANIMATION_NAMES[State.BITING]:
		if _ant_in_biting_area != null:
			if _ant_in_biting_area.has_method("die"):
				_ant_in_biting_area.die()
				_ant_in_biting_area = null
				set_state(State.WALKING)
			else:
				print("ERROR: Can not kill ant in biting area because it doesn't have a die method")

func _on_SenseArea_body_entered(body):
	if is_eadible(body) and _current_state == State.WALKING:
		# TODO maybe we should look into using behaviour trees here.
		# TODO we miss ants that enter the sense area while we are killing another one
		# change orientation so that the body is in front of us
		set_orientation((body.global_position - global_position).angle())
		_ant_in_sensing_area = body
		set_state(State.HUNTING)

func _on_SenseArea_body_exited(body):
	if _current_state == State.HUNTING and _ant_in_sensing_area == body:
		_ant_in_sensing_area = null
		set_state(State.WALKING)
