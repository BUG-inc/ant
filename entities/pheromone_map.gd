extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var width = 100
export var height = 100
export var cell_height = 10
export var cell_width = 10
export var PHEROMONE_INCREMENT = 0.1
# each cell stores pheromones
var cells = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# initialize cells
	for _h in range(height):
		cells.append([])
		for _w in range(width):
			cells[-1].append(0.0)

func get_cell_index(position: Vector2, pos_in_local_frame: bool = false):
	"""
	Return [row, column] index from a position.
	Returns null if out of range.
	"""
	if not pos_in_local_frame:
		position = transform.inverse() * position
	var cell_index = [int(position.y / cell_height), int(position.x / cell_width)]
	if cell_index[0] < 0 or cell_index[0] >= height:
		return null
	if cell_index[1] < 0 or cell_index[1] >= width:
		return null
	return cell_index
	
func get_pheromone_level(position: Vector2) -> float:
	"""
	Return the pheromone level at a global position
	"""
	var cell_index = get_cell_index(position)
	if cell_index != null:
		return cells[cell_index[0]][cell_index[1]]
	return 0.0

func add_pheromone(position: Vector2,  increment: float = PHEROMONE_INCREMENT):
	var cell_index = get_cell_index(position)
	if cell_index != null:
		cells[cell_index[0]][cell_index[1]] += increment

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("add_pheromone"):
		var cell_index = get_cell_index(get_local_mouse_position(), true)
		if cell_index == null:
			return
		cells[cell_index[0]][cell_index[1]] += PHEROMONE_INCREMENT
		update()

func _draw():
	var cell_rect = Rect2(0.0, 0.0, cell_width, cell_height)
	var color = Color(0, 0, 0, 1.0)
	for h in range(height):
		for w in range(width):
			cell_rect.position.x = w * cell_width
			cell_rect.position.y = h * cell_height
			color.r = cells[h][w]
			color.a = cells[h][w]
			draw_rect(cell_rect, color)
