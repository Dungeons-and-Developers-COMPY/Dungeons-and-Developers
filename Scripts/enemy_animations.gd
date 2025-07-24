extends AnimatedSprite2D

func die():
	play("die")

func _on_animation_finished() -> void:
	if animation == "attack":
		play("idle")
