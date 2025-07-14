extends CharacterBody2D

signal stopped_moving

var target_position = null
var speed = 100
var arrived_threshold = 1.0

func _physics_process(delta):
	if target_position:
		var direction = global_position.direction_to(target_position)
		var distance = global_position.distance_to(target_position)
		if distance < arrived_threshold:
			global_position = target_position  # snap to final pos
			target_position = null
			velocity = Vector2.ZERO
			emit_signal("stopped_moving")
			print("STOPPED")
		else:
			velocity = direction * speed
			move_and_slide()  # Or move_and_collide()
	else:
		velocity = Vector2.ZERO
		
func set_target_pos(x, y):
	target_position = Vector2(x, y)
