extends Area2D

onready var _mutex: Mutex = Mutex.new()
onready var _in_range_cells: Dictionary = {}
onready var _cells_to_clear: Array = []
onready var _rays = []

export var ForegroundLayer: int = 0b0000;
export var CellInflationFactor: float = 1.1;

func _to_key(cell_position: Vector2) -> Array:
	return [int(cell_position.x), int(cell_position.y)]

func _sees_tile(current_position: Vector2, cell_world_position: Vector2, cell_grid_position: Vector2, cell_size: Vector2, space_state: Physics2DDirectSpaceState) -> bool:
	var result = space_state.intersect_ray(current_position, cell_world_position, [], ForegroundLayer);
	if result.empty(): # clear sight
		return true;
	if result["metadata"] == cell_grid_position:  # same tile location
		return true;
	return cell_world_position.distance_to(result["position"]) < CellInflationFactor * cell_size.length() / 2.0;

func _physics_process(delta):
	#if Input.is_mouse_button_pressed(0):
	_rays.clear()
	var space_state = get_world_2d().direct_space_state;
	var current_position: Vector2 = to_global(position)
	_mutex.lock()
	for cell_grid_position in _in_range_cells.keys():
		var tile_map = _in_range_cells[cell_grid_position]["TileMap"];
		var cell_world_position = tile_map.to_global(tile_map.map_to_world(cell_grid_position) + tile_map.cell_size / 2.0)
		#wdprint("Cell world position=" + str(cell_world_position) + " my position=" + str(current_position))
		_rays.append([current_position, cell_world_position])
		if _sees_tile(current_position, cell_world_position, cell_grid_position, tile_map.cell_size, space_state):
			print("erasing cell " + str(cell_grid_position))
			_cells_to_clear.append(_in_range_cells[cell_grid_position])
			_in_range_cells.erase(cell_grid_position)
#			tile_map.set_cell(cell_grid_position.x, cell_grid_position.y, TileMap.INVALID_CELL);
#		print("physics cell check done")
	_mutex.unlock()
#			tile_map.update_dirty_quadrants()
			#_rays[cell_grid_position].append([current_position, corner_position])
			#if not result.empty() and result["collider"] == tile_map and result["metadata"] == cell_grid_position:

func _process(delta):
	for cell_entry in _cells_to_clear:
		print("clearing cell " + str(cell_entry.cell_position))
		cell_entry["TileMap"].set_cell(cell_entry.cell_position.x, cell_entry.cell_position.y, TileMap.INVALID_CELL)
#		cell_entry.TileMap.update_dirty_quadrants()
		print("clearing cell done")
	update()
	_cells_to_clear.clear()
#	update()

# signal receiver of body shape entered. Should be set up so that only the mist TileMap is sensed by the Area2D
func _on_unveal_area_body_shape_entered(body_rid: RID, body: TileMap, body_shape_index: int, local_shape_index: int):
	var cell: Vector2 = Physics2DServer.body_get_shape_metadata(body_rid, body_shape_index);
	_mutex.lock()
	if cell in _in_range_cells:
		print("WARNING: Cell entered shape but was already in cache")
	else:
		_in_range_cells[cell] = {"cell_position": cell, "TileMap": body}
	_mutex.unlock()
	print("Cell entered " + str(body_shape_index) + " cell coordinates are " + str(cell))

func _draw():
	for ray in _rays:
		draw_line(to_local(ray[0]), to_local(ray[1]), Color(1, 0, 0, 1), 2.0);

func _on_unveal_area_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	var cell: Vector2 = Physics2DServer.body_get_shape_metadata(body_rid, body_shape_index);
	_mutex.lock()
	if cell in _in_range_cells:
		_in_range_cells.erase(cell)
	_mutex.unlock()
	print("Cell exited " + str(body_shape_index) + " cell coordinates are " + str(cell))
