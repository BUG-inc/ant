extends TileMap

# Declare member variables here. Examples:
var _damaged_cells: Dictionary = {}  # stores for every damaged cell how many lifepoints it has left


func dig_hole(position: Vector2):
	var cell: Vector2 = world_to_map(position)
	var cell_value: int = get_cell(cell.x, cell.y)
	# print("dig hole called. position=" + str(position) + ", cell position=" + str(cell) + " cell value=" + str(cell_value))
	if cell_value == INVALID_CELL:
		return
	set_cell(cell.x, cell.y, INVALID_CELL)
	update_dirty_quadrants()
	update_bitmask_area(cell)
	# get the health value of the cell
	pass
