extends CharacterBody2D

signal stopped_moving
signal console(text: String)

var target_position = null
var speed = 150
var arrived_threshold = 1.0
var is_stunned = false

@onready var animator = $AnimatedSprite2D 

func _physics_process(_delta):
	if is_stunned:
		return
	
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

func attack():
	is_stunned = true
	animator.play("attack")

func _on_animation_finished() -> void:
	if animator.animation == "attack":
		is_stunned = false
		animator.play("idle")
		
func stun():
	is_stunned = true
	animator.play("damage")
	await get_tree().create_timer(Globals.stun_time).timeout
	is_stunned = false
	animator.play("idle")
