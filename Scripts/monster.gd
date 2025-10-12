# triggers monster animations
extends Node2D

@onready var animator = $AnimatedSprite2D

func die():
	animator.die()
	
func attack():
	animator.attack()
