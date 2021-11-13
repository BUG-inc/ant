extends Node2D


func use_level_camera(val: bool, pos: Vector2):
	"""Toggle the level camera."""
	$camera_position/camera.current = val
	$camera_position.set_active(val)
	$camera_position.position = pos
