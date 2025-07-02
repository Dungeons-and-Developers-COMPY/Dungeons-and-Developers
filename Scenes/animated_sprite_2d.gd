extends AnimatedSprite2D



#func _process(delta: float) -> void:
	#if Input.is_action_pressed("attack"):
		#play("attack")
	#elif Input.is_action_pressed("die"):
		#play("die")
#
#
#func _on_animation_finished() -> void:
	#if animation == "attack":
		#play("idle")
		
		
