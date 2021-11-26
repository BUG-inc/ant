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
	ATTACKING=1
	DEAD=2
}
const STATE_NAMES = ["walking", "attacking", "dead"]

var _time_since_dir_change = 0.0
var _current_state: int = State.WALKING
var _gen = RandomNumberGenerator.new()
var _ant_in_biting_area: BaseAnt = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func set_state(new_state: int):
	_current_state = new_state

func _physics_process(delta):
	_time_since_dir_change += delta
	if _time_since_dir_change >= dir_change_interval:
		_time_since_dir_change = 0.0
		_dir = Vector2(1, 0).rotated(2.0 * PI * _gen.randf())
		rotation = atan2(_dir.y, _dir.x) + PI / 2
	var velocity: Vector2 = move_and_slide(speed * _dir)
	# if the beetle is stuck force a direction change
	if velocity.length() < min_speed:
		_time_since_dir_change = dir_change_interval

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$AnimationPlayer.play(STATE_NAMES[_current_state])

func _on_BiteArea_body_entered(body):
	#print("body in biting area: " + str(body.get_groups()))
	if body.is_in_group("player") or body.is_in_group("npc_ants"):
		if not body.has_method("is_dead"):
			print("ERROR: Body that belongs to ant group does not have is_dead function!")
			return
		if _ant_in_biting_area == null and not body.is_dead():
			_ant_in_biting_area = body
			set_state(State.ATTACKING)

func _on_BiteArea_body_exited(body):
	#print("body left area: " + str(body.get_groups()))
	if body == _ant_in_biting_area:
		_ant_in_biting_area = null
		set_state(State.WALKING)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == STATE_NAMES[State.ATTACKING]:
		if _ant_in_biting_area != null:
			if _ant_in_biting_area.has_method("die"):
				_ant_in_biting_area.die()
				_ant_in_biting_area = null
				set_state(State.WALKING)
			else:
				print("ERROR: Can not kill ant in biting area because it doesn't have a die method")
