extends Node2D

@onready var animator = $AnimatedSprite2D

func die():
	animator.die()
