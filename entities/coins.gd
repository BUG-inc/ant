extends StaticBody2D

export var total_resources = 10
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	# save resource type in meta data
	$gatherArea.set_meta("resource_type", "coins")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_gatherArea_area_entered(area:Area2D) -> void:
	total_resources -= 1
	if total_resources < 0:
		queue_free()
