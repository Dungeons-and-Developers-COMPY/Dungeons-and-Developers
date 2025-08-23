extends AnimatedSprite2D

func die():
	play("die")
	
func attack():
	play("attack")

func _on_animation_finished() -> void:
	if animation == "attack":
		play("idle")
