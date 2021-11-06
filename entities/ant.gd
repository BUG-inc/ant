extends "res://entities/entity.gd"


export (int) var speed = 200
var _gen = RandomNumberGenerator.new()
var velocity = Vector2()

func _physics_process(_delta: float) -> void:
    
    _gen.randomize()
    var dir = Vector2(_gen.randf_range(-1, 1), _gen.randf_range(-1, 1))
    dir = dir.normalized()
    print(dir)
    velocity = move_and_slide(speed * dir)
    
