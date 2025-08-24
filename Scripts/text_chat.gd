extends Control

@onready var type_box = $Panel/TypeEdit
@onready var chat_box: RichTextLabel = $ChatBox

###### buttons and shit
signal mic_toggled(enabled: bool)
signal vol_toggled(enabled: bool)

signal send_chat(message: String)

func _ready():
	type_box.connect("gui_input", Callable(self, "_on_type_box_input"))

func _on_type_box_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER:
			#if event.shift_pressed:
				## Insert a newline manually
				#type_box.text += ("\n")
				#type_box.accept_event()
			#else:
			_on_send_button_pressed()
			type_box.accept_event()
#func _on_type_box_input(event: InputEvent) -> void:
	#if event is InputEventKey and event.pressed and not event.echo:
		#if event.keycode == KEY_ENTER:
			#if event.shift_pressed:
				## Insert a newline at the current cursor
				#type_box.insert_text("\n", type_box.caret_line, type_box.caret_column)
#
				## Move caret to end of text
				#var last_line: int = type_box.cursor_get_line()
				#var last_col: int = type_box.cursor_get_column()
#
				#type_box.set_caret_line(last_line)
				#type_box.set_caret_column(last_col)
				#type_box.accept_event()
			#else:
				#_on_send_button_pressed()
				#type_box.accept_event()

	
func output_message(message: String):
	chat_box.text += "\n" + message
	chat_box.scroll_to_line(chat_box.get_line_count() - 1)

func _on_send_button_pressed() -> void:
	var tex = type_box.text.strip_edges()
	if tex != "":
		emit_signal("send_chat", "Teammate: " + tex)
		output_message("You: " + tex)
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
