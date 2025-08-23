extends Node2D

signal start1v1

@onready var username_label: Label = $Username

func _ready() -> void:
	pass

func _on_play_pressed() -> void:
	emit_signal("start1v1")

func _on_leaderboard_pressed() -> void:
	pass # Replace with function body.

func display_username():
	username_label.text = "Welcome!\n" + Globals.username.to_upper() 
