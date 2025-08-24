extends Node2D

signal start1v1
signal start2v2
signal show_leaderboard

@onready var username_label: Label = $Username

func _on_v_1_pressed() -> void:
	if Globals.is_2v2:
		emit_signal("start2v2")
	else:
		emit_signal("start1v1")

func _on_leaderboard_pressed() -> void:
	emit_signal("show_leaderboard")

func display_username():
	username_label.text = "Welcome!\n" + Globals.username.to_upper()
