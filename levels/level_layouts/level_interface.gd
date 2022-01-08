tool
extends Node2D

var queen_finder = preload("res://levels/level_layouts/astar2d.gd").new()
var astar_list = [queen_finder]  # expand with other astar instances to have them initialised in the level's free space
var tile_id_map = {}  # Vector2d -> tile_id
var queen_in_tilemap = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	# cover the world with mist
	if get_node_or_null("Mist") == null:
		print("Warning: No mist tilemap found in level.")
		return
	if get_node_or_null("Foreground") == null:
		print("Warning: no Foreground tilemap found in level.")
		return

	var bounding_box : Rect2 = $Background.get_used_rect()
	var min_cell : Vector2 = bounding_box.position
	var max_cell : Vector2 = bounding_box.position + bounding_box.size
	for x in range(min_cell.x, max_cell.x + 1):
		for y in range(min_cell.y, max_cell.y + 1):
			if not Engine.editor_hint:
				$Mist.set_cell(x, y, 0)
			_try_to_add_astar(x, y)

	for empty_tile in tile_id_map.keys():
		_connect_astar(empty_tile.x, empty_tile.y)

	if Engine.editor_hint:
		_show_astar_costs(queen_finder, tile_id_map[queen_in_tilemap])

func set_queen_position(pos: Vector2):
	"""
	Set the location of the queen's position, to update the queen_finder .
	"""
	queen_in_tilemap = $Foreground.world_to_map(pos)

func get_bounding_box() -> Rect2:
	"""
	Return a bounding box (in world frame) that captures the whole level.
	"""
	var cell_bounding_box = $Background.get_used_rect()
	return Rect2($Background.map_to_world(cell_bounding_box.position), cell_bounding_box.size * $Background.cell_size)

func _try_to_add_astar(x: int, y: int):
	"""
	Attempt to add an astar point at the tilemap position (x, y). 
	"""
	if _empty_cell(x, y):  # tile is free space
		for astar in astar_list:
			var newid = astar.get_available_point_id()
			astar.add_point(newid, Vector2(x, y))
			tile_id_map[Vector2(x, y)] = newid

func _connect_astar(x: int, y: int):
	"""
	Find the adjacencies for the tile at (x, y)
	"""
	var adjacent_cells = []
	var right = Vector2(x + 1, y)
	var left = Vector2(x - 1, y)
	var top = Vector2(x, y + 1)
	var down = Vector2(x, y - 1)

	if _empty_cell(right.x, right.y) and right in tile_id_map:
		adjacent_cells.append(right)
	if _empty_cell(left.x, left.y) and left in tile_id_map:
		adjacent_cells.append(left)
	if _empty_cell(top.x, top.y) and top in tile_id_map:
		adjacent_cells.append(top)
	if _empty_cell(down.x, down.y) and down in tile_id_map:
		adjacent_cells.append(down)

	for astar in astar_list:
		for cell in adjacent_cells:
			astar.connect_points(tile_id_map[Vector2(x, y)], tile_id_map[cell])

func _show_astar_costs(astar: AStar2D, target_id: int):
	for id in tile_id_map.values():
		var label = Label.new()
		label.text = str(astar.compute_cost(id, target_id))
		var tile_pos = astar.get_point_position(id)
		var world_pos = $Foreground.map_to_world(tile_pos)
		label.set_position(world_pos)
		add_child(label)
		# print(astar.compute_cost(id, target_id))

func _empty_cell(x: int, y: int) -> bool:
	"""
	Check if the tilemap cell at (x, y) is empty.
	"""
	return $Foreground.get_cell(x, y) == $Foreground.INVALID_CELL

func _on_player_dig_hole(position):
	if $Foreground.has_method("dig_hole"):
		$Foreground.dig_hole(position)

func _on_clear_mist(position, radius):
	if $Mist.has_method("unveil"):
		$Mist.unveil(position, radius)
