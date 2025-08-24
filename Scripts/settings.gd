extends Node2D

@onready var master_vol: HSlider = $NinePatchRect/MasterVol/HSlider
@onready var music_vol: HSlider = $NinePatchRect/MusicVol/HSlider
@onready var sfx_vol: HSlider = $NinePatchRect/SFXVol/HSlider

signal hide_settings 

func _ready() -> void:
	master_vol.set_bus_name("Master")
	music_vol.set_bus_name("Music")
	sfx_vol.set_bus_name("SFX")


func _on_close_button_pressed() -> void:
	emit_signal("hide_settings")
