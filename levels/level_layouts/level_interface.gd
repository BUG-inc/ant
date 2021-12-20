extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	# cover the world with mist
	var bounding_box : Rect2 = $Background.get_used_rect()
	var min_cell : Vector2 = bounding_box.position
	var max_cell : Vector2 = bounding_box.position + bounding_box.size
	for x in range(min_cell.x, max_cell.x + 1):
		for y in range(min_cell.y, max_cell.y + 1):
			$Mist.set_cell(x, y, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func get_bounding_box() -> Rect2:
	"""
	Return a bounding box (in world frame) that captures the whole level.
	"""
	var cell_bounding_box = $Background.get_used_rect()
	return Rect2($Background.map_to_world(cell_bounding_box.position), cell_bounding_box.size * $Background.cell_size)

func _on_player_dig_hole(position):
	if $Foreground.has_method("dig_hole"):
		$Foreground.dig_hole(position)

func _on_clear_mist(position, radius):
	if $Mist.has_method("unveil"):
		$Mist.unveil(position, radius)
