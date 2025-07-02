extends CharacterBody2D

var target_position = null
var speed = 100

func _physics_process(delta):
	if target_position:
		var direction = global_position.direction_to(target_position)
		velocity = direction * speed
		move_and_slide()  # Or move_and_collide()
	else:
		velocity = Vector2.ZERO
		
func set_target_pos(x, y):
	target_position = Vector2(x, y)
