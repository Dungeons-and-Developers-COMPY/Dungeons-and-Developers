extends Node2D

@onready var menu = $MainMenu
@onready var game = $Game

func _ready() -> void:
	menu.start1v1.connect(start1v1)
	menu.start2v2.connect(start2v2)
	game.hide()
	menu.show()
	
func start2v2():
	pass
func start1v1():
	menu.hide()
	game.show()
	game.show_end("Connecting to 1v1 server...")
	if OS.get_name() == "Web":
		game.js_handler.login()
	else:
		game.question_handler.login()
