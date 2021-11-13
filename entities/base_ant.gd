extends "res://entities/entity.gd"

export (int) var speed = 200
var _dir = Vector2()
var velocity = Vector2()


func _process(_delta: float) -> void:
	_update_animation(_dir)

func _update_animation(dir: Vector2) -> void:
	if dir.x > 0:
		$AnimatedSprite.flip_h = false

	if dir.x < 0:
		$AnimatedSprite.flip_h = true
	
	if is_equal_approx(velocity.length(), 0):
		$AnimatedSprite.animation = "idle"
	else:
		$AnimatedSprite.animation = "walking"

	$AnimatedSprite.playing = true