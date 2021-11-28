extends StaticBody2D

var resource_size_scale = 2.0
var scale_offset = 0.4
var max_resources = 100.0
export var total_resources = 10.0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	# save resource type in meta data
	if total_resources > max_resources:
		total_resources = max_resources

	_shrink()
	$gatherArea.set_meta("resource_type", "coins")
	$gatherArea.set_meta("resource_node", self)

func collect():
	total_resources -= 1
	_shrink()

	if total_resources < 0:
		queue_free()
		return 0
	else:
		return 1

func _shrink():
	$AnimatedSprite.scale.x = resource_size_scale * (total_resources / max_resources) + scale_offset
	$AnimatedSprite.scale.y = resource_size_scale * (total_resources / max_resources) + scale_offset
