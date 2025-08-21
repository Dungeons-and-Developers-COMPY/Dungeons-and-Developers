# volume_slider.gd
extends HSlider

@export var bus_name: String = "Master"
var bus_index: int

func _ready() -> void:
	# Find the index of the audio bus by its name.
	bus_index = AudioServer.get_bus_index(bus_name)
	# Set the slider's initial value to the current bus volume.
	# We must convert the volume from decibels (dB) to a linear scale (0-1).
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

	# Connect the slider's value_changed signal to a function.
	value_changed.connect(_on_value_changed)

func _on_value_changed(new_value: float) -> void:
	# Set the audio bus volume based on the new slider value.
	# We must convert the linear slider value back to decibels (dB).
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(new_value))
