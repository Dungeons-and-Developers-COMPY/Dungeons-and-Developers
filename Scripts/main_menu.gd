# handles buttons pressed on main menu, and shows player username

extends Node2D

signal start1v1
signal show_leaderboard

@onready var username_label: Label = $Username

func _ready() -> void:
	pass

func _on_play_pressed() -> void:
	emit_signal("start1v1")

func _on_leaderboard_pressed() -> void:
	emit_signal("show_leaderboard")

func display_username():
	username_label.text = "Welcome!\n" + Globals.username.to_upper() 
