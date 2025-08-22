extends Node2D

signal start1v1

@onready var music_vol_slider: HSlider = $NinePatchRect/HSlider

func _ready() -> void:
	music_vol_slider.set_bus_name("Music")

func _on_play_pressed() -> void:
	emit_signal("start1v1")

func _on_leaderboard_pressed() -> void:
	pass # Replace with function body.
