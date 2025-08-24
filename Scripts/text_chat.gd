extends Control

@onready var type_box = $Panel/TypeEdit
@onready var chat_box: RichTextLabel = $ChatBox

###### buttons and shit
signal mic_toggled(enabled: bool)
signal vol_toggled(enabled: bool)

####### disable copy paste in text chat and connect buttons
#func _ready():
	##type_box.selection_enabled = false
	##type_box.context_menu_enabled = false  # removes right-click menu
	##type_box.set_shortcut_keys_enabled(false) # removes built-in shortcuts

signal send_chat(message: String)

func output_message(message: String):
	chat_box.text += "\n" + message

func _on_send_button_pressed() -> void:
	emit_signal("send_chat", "Teammate: " + type_box.text)
	output_message("You: " + type_box.text)
	type_box.clear()


func _on_emoji_button_pressed() -> void:
	pass # Replace with function body.

func _on_mic_button_toggled(toggled_on: bool) -> void:
	emit_signal("mic_toggled", toggled_on)
	output_message("Mic Toggled: " + str(!toggled_on))
	#pass # Replace with function body.
func _on_vol_button_toggled(toggled_on: bool) -> void:
	emit_signal("vol_toggled", toggled_on)
	output_message("Volume Toggled: " + str(!toggled_on))
