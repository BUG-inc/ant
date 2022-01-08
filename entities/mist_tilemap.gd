extends TileMap

export var foreground_layer: int = 0b0100;
export var cell_inflation_factor: float = 1.5;
onready var _mutex: Mutex = Mutex.new()
onready var _cells_to_unveil = {}

func _sees_tile(current_position: Vector2, cell_world_position: Vector2, cell_grid_position: Vector2, space_state: Physics2DDirectSpaceState) -> bool:
	var result = space_state.intersect_ray(current_position, cell_world_position, [], foreground_layer);
	if result.empty(): # clear sight
		return true;
	if result["metadata"] == cell_grid_position:  # same tile location
		return true;
	return cell_world_position.distance_to(result["position"]) < cell_inflation_factor * cell_size.length() / 2.0;
	
func _physics_process(delta):
	var space_state := get_world_2d().direct_space_state;
	_mutex.lock();
	for cell in _cells_to_unveil.keys():
		var cell_center := to_global(map_to_world(cell) + cell_size / 2.0)
		for source_position in _cells_to_unveil[cell]:
			if _sees_tile(source_position, cell_center, cell, space_state):
				set_cell(cell.x, cell.y, TileMap.INVALID_CELL);
				break
	_cells_to_unveil = {}
	_mutex.unlock()

func unveil(position: Vector2, radius: float):
	"""
	Unveil all mist cells whose center fall within a circle of given radius at
	the given position.
	"""
	var grid_position := self.world_to_map(position)
	var max_cell_delta_x = ceil(radius / self.cell_size[0])
	var max_cell_delta_y = ceil(radius / self.cell_size[1])
	_mutex.lock()
	for y in range(grid_position.y - max_cell_delta_y, grid_position.y + max_cell_delta_y + 1):
		for x in range(grid_position.x - max_cell_delta_x, grid_position.x + max_cell_delta_x + 1):
			var cell_index := Vector2(x, y);
			var cell_center := to_global(map_to_world(cell_index) + cell_size / 2.0)
			if get_cellv(cell_index) != TileMap.INVALID_CELL and position.distance_squared_to(cell_center) < radius * radius:
				if cell_index in _cells_to_unveil:
					_cells_to_unveil[cell_index].append(position)
				else:
					_cells_to_unveil[cell_index] = [position]
	_mutex.unlock()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
