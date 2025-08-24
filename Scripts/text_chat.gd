extends Control
@onready var type_box = $Panel/TypeEdit
@onready var chat_box: RichTextLabel = $ChatBox

###### buttons and shit
signal mic_toggled(enabled: bool)
signal vol_toggled(enabled: bool)
signal send_chat(message: String)

# Emoji system variables
var emoji_visible = false
var emojis = ["😀", "😂", "😍", "🤔", "👍", "👎", "❤️", "🔥", "💯", "🎉", "😢", "😡", "🤖", "💀", "👻", "🎮", "⚡", "💪", "🏆", "🚀"]

func _ready():
	type_box.connect("gui_input", Callable(self, "_on_type_box_input"))
	#setup_emoji_panel()

#func setup_emoji_panel():
	## Create emoji panel if it doesn't exist
	#if not has_node("Panel/EmojiPanel"):
		#emoji_panel = Panel.new()
		#emoji_panel.name = "EmojiPanel"
		#$Panel.add_child(emoji_panel)
	#
	## Position the emoji panel above the type box
	#emoji_panel.position = Vector2(type_box.position.x, type_box.position.y - 200)
	#emoji_panel.size = Vector2(300, 180)
	#emoji_panel.visible = false
	#
	## Create a grid container for emojis
	#var grid_container = GridContainer.new()
	#grid_container.columns = 5
	#grid_container.position = Vector2(10, 10)
	#emoji_panel.add_child(grid_container)
	#
	## Add emoji buttons
	#for i in range(emojis.size()):
		#var emoji_btn = Button.new()
		#emoji_btn.text = emojis[i]
		#emoji_btn.custom_minimum_size = Vector2(40, 40)
		#emoji_btn.pressed.connect(_on_emoji_selected.bind(emojis[i]))
		#grid_container.add_child(emoji_btn)

func _on_type_box_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER:
			if event.shift_pressed:
				# Insert a newline at the current cursor position
				var current_text = type_box.text
				var cursor_pos = type_box.get_caret_column()
				var cursor_line = type_box.get_caret_line()
				
				# Get the current line text
				var lines = current_text.split("\n")
				if cursor_line < lines.size():
					var line_text = lines[cursor_line]
					var new_line = line_text.substr(0, cursor_pos) + "\n" + line_text.substr(cursor_pos)
					lines[cursor_line] = new_line.substr(0, new_line.find("\n"))
					lines.insert(cursor_line + 1, new_line.substr(new_line.find("\n") + 1))
				else:
					lines.append("")
				
				type_box.text = "\n".join(lines)
				# Move cursor to next line, beginning
				type_box.set_caret_line(cursor_line + 1)
				type_box.set_caret_column(0)
				type_box.accept_event()
			else:
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

#func _on_emoji_button_pressed() -> void:
	#emoji_visible = !emoji_visible
	#emoji_panel.visible = emoji_visible
	#
	## Change button appearance to indicate state
	#if emoji_visible:
		#emoji_button.text = "😀 Close"
	#else:
		#emoji_button.text = "😀"

func _on_emoji_selected(emoji: String):
	# Add the selected emoji to the current text
	var current_text = type_box.text
	var cursor_line = type_box.get_caret_line()
	var cursor_column = type_box.get_caret_column()
	
	# Calculate absolute cursor position in the entire text
	var lines = current_text.split("\n")
	var absolute_cursor_pos = 0
	
	# Add lengths of all lines before current line (including newline characters)
	for i in range(cursor_line):
		if i < lines.size():
			absolute_cursor_pos += lines[i].length() + 1  # +1 for the newline character
	
	# Add column position within current line
	absolute_cursor_pos += cursor_column
	
	# Insert emoji at absolute cursor position
	var new_text = current_text.substr(0, absolute_cursor_pos) + emoji + current_text.substr(absolute_cursor_pos)
	type_box.text = new_text
	
	# Calculate new cursor position after emoji insertion
	var new_absolute_pos = absolute_cursor_pos + emoji.length()
	
	# Convert back to line/column format
	var new_lines = new_text.split("\n")
	var running_pos = 0
	var new_line = 0
	var new_column = 0
	
	for i in range(new_lines.size()):
		var line_length = new_lines[i].length()
		if new_absolute_pos <= running_pos + line_length:
			new_line = i
			new_column = new_absolute_pos - running_pos
			break
		running_pos += line_length + 1  # +1 for newline
	
	# Set cursor to new position
	type_box.set_caret_line(new_line)
	type_box.set_caret_column(new_column)
	
	# Keep focus on the text box
	type_box.grab_focus()
	
	# Optionally close emoji panel after selection
	# Uncomment the next four lines if you want the panel to close after selecting an emoji
	# emoji_visible = false
	# emoji_panel.visible = false
	# emoji_button.text = "😀"

func _on_mic_button_toggled(toggled_on: bool) -> void:
	emit_signal("mic_toggled", toggled_on)
	output_message("Mic Toggled: " + str(!toggled_on))
	#pass # Replace with function body.

func _on_vol_button_toggled(toggled_on: bool) -> void:
	emit_signal("vol_toggled", toggled_on)
	output_message("Volume Toggled: " + str(!toggled_on))

# Handle clicking outside emoji panel to close it
#func _input(event):
	#if event is InputEventMouseButton and event.pressed and emoji_visible:
		## Check if click was outside emoji panel
		#var emoji_rect = Rect2(emoji_panel.global_position, emoji_panel.size)
		#var emoji_btn_rect = Rect2(emoji_button.global_position, emoji_button.size)
		#
		#if not emoji_rect.has_point(event.global_position) and not emoji_btn_rect.has_point(event.global_position):
			#emoji_visible = false
			#emoji_panel.visible = false
			#emoji_button.text = "😀"
