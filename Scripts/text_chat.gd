extends Control

@onready var type_box = $Panel/TypeEdit
@onready var chat_box: RichTextLabel = $ChatBox

signal send_chat(message: String)

func output_message(message: String):
	chat_box.text += "\n" + message

func _on_send_button_pressed() -> void:
	emit_signal("send_chat", type_box.text)
	output_message("You: " + type_box.text)
	type_box.clear()


func _on_emoji_button_pressed() -> void:
	pass # Replace with function body.
