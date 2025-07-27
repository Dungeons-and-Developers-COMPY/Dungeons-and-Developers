extends CharacterBody2D

signal stopped_moving
signal console(text: String)

var target_position = null
var speed = 100
var arrived_threshold = 1.0

@onready var animator = $AnimatedSprite2D 

func _physics_process(_delta):
	if target_position:
		var direction = global_position.direction_to(target_position)
		var distance = global_position.distance_to(target_position)
		
		#if direction.x != 0:
			#animator.flip_h = direction.x < 0
		
		if distance < arrived_threshold:
			global_position = target_position  # snap to final pos
			target_position = null
			velocity = Vector2.ZERO
			animator.play("idle")
			emit_signal("stopped_moving")
			print("STOPPED") 
		else:
			velocity = direction * speed
			move_and_slide()
			if abs(velocity.x) > 1:
				animator.flip_h = velocity.x < 0
			
			if animator.animation != "walk":
				animator.play("walk")
	else:
		velocity = Vector2.ZERO
		if animator.animation != "idle":
				animator.play("idle")
		
func set_target_pos(x, y):
	target_position = Vector2(x, y)


func _on_animation_finished() -> void:
	if animator.animation == "damage":
		animator.play("idle")
		
func stun():
	animator.play("damage")
