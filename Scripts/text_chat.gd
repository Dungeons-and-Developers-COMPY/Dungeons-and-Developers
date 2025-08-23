extends Control

@onready var type_box = $Panel/TypeEdit
@onready var chat_box: RichTextLabel = $ChatBox

signal send_chat(message: String)

##### buttons and shit
signal mic_toggled(enabled: bool)
signal volume_toggled(enabled: bool)

@onready var mic_button: Button = $Panel/MicButton
@onready var volume_button: Button = $Panel/VolButton

var mic_enabled := true
var volume_enabled := true

####### disable copy paste in text chat and connect buttons
#func _ready():
	##type_box.selection_enabled = false
	##type_box.context_menu_enabled = false  # removes right-click menu
	##type_box.set_shortcut_keys_enabled(false) # removes built-in shortcuts
	#mic_button.pressed.connect(_on_mic_button_pressed)
	#volume_button.pressed.connect(_on_volume_button_pressed)

func output_message(message: String):
	chat_box.text += "\n" + message

#####
#func output_message(message: String, is_local: bool = false):
	#if is_local:
		#chat_box.text += "\nYou: " + message
	#else:
		#chat_box.text += "\nTeammate: " + message
#func _on_send_button_pressed() -> void:
	#var msg = type_box.text
	#emit_signal("send_chat", msg)
	#output_message(msg, true)  # mark as local
	#type_box.clear()

func _on_send_button_pressed() -> void:
	emit_signal("send_chat", type_box.text)
	output_message("You: " + type_box.text)
	type_box.clear()

func _on_emoji_button_pressed() -> void:
	pass # Replace with function body.

####### buttons
#func _on_mic_button_pressed():
	#mic_enabled = !mic_enabled
	#emit_signal("mic_toggled", mic_enabled)
#
#func _on_volume_button_pressed():
	#volume_enabled = !volume_enabled
	#emit_signal("volume_toggled", volume_enabled)
