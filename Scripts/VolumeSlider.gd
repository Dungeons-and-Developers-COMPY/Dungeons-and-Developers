# changes the volume of the related audio bus to the slider's value
extends HSlider

@export var bus_name: String = "Master"
var bus_index: int

func _ready() -> void:
	# connect the slider's value_changed signal to a function
	value_changed.connect(_on_value_changed)

func _on_value_changed(new_value: float) -> void:
	# set audio bus volume based on new slider value.
	# convert the linear slider value to dB
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(new_value))

func set_bus_name(bus: String):
	bus_name = bus
	bus_index = AudioServer.get_bus_index(bus_name)
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
