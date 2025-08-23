extends Node2D

@onready var menu = $MainMenu
@onready var game = $Game
@onready var settings_panel: Panel = $Panel
@onready var settings: Node2D = $Panel/Settings

func _ready() -> void:
	menu.start1v1.connect(start1v1)
	settings.hide_settings.connect(hide_settings)
	game.js_handler.send_username.connect(save_username)
	game.hide()
	settings_panel.hide()
	menu.show()
	

func start1v1():
	menu.hide()
	game.show()
	game.show_end("Connecting to 1v1 server...", 160)
	if OS.get_name() == "Web":
		game.js_handler.login()
	else:
		game.question_handler.login()


func _on_settings_button_pressed() -> void:
	settings_panel.show()

func hide_settings():
	settings_panel.hide()

func save_username(logged_in: bool, username: String):
	Globals.username = username
	
