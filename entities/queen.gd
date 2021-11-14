extends KinematicBody2D

class_name Queen

var resources: Dictionary = {}

signal resource_update
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	reset_resources()asss

func deliver_resource(type: String, number: int):
	resources[type] += number
	print("Resources of type " + type + " number: " + str(number))
	emit_signal("resource_update")

func reset_resources():
	resources = {"coins": 0}
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
