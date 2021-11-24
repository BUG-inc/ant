extends KinematicBody2D

class_name Queen

export var ant_birth_cost = 10
export var init_coins = 10

var resources: Dictionary = {}
var basic_ant_birth_resource = "coins"
var _ant_birth = preload("res://entities/ant_birth.tscn")
export var birth_ant_position = Vector2()

signal resource_update(type, number)
signal birthing(position)

func _ready():
	reset_resources()

func _physics_process(delta: float):
	check_can_birth()

func deliver_resource(type: String, number: int):
	resources[type] += number
	# print("Resources of type " + type + " number: " + str(number))
	emit_signal("resource_update", type, resources[type])

func check_can_birth():
	"""Check if there are enough resources to birth a new ant."""
	if resources[basic_ant_birth_resource] >= ant_birth_cost and not $BirthAnimator.is_playing():
		resources[basic_ant_birth_resource] -= ant_birth_cost
		emit_signal("resource_update", basic_ant_birth_resource, resources[basic_ant_birth_resource])
		$BirthAnimator.play("BirthNewAnt")

func reset_resources():
	resources = {"coins": init_coins}
	for resource in resources:
		emit_signal("resource_update", resource, resources[resource])

func birthing():
	var birth_ant = _ant_birth.instance()
	$AudioStreamPlayer.playing = true
	birth_ant.position = birth_ant_position
	birth_ant.get_node("AnimationPlayer").connect("animation_finished", self, "_on_birth_ant_animation_finished")
	birth_ant.add_to_group("birth_ant")
	print(birth_ant_position)
	add_child(birth_ant)

func _on_FeastTimer_timeout() -> void:
	$MainAnimation.animation = "idle"


func _on_birth_ant_animation_finished(_animation: String):
	for ant in get_tree().get_nodes_in_group("birth_ant"):
		emit_signal("birthing", to_global(ant.position + ant.get_node("Default").position))
		ant.queue_free()

