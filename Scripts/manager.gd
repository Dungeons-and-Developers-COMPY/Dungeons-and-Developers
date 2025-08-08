extends Node2D

@onready var menu = $MainMenu
@onready var game = $Game

func _ready() -> void:
	menu.start1v1.connect(start1v1)
	menu.start2v2.connect(start2v2)
	game.hide()
	menu.show()
	
func start2v2():
	game.js_handler.login()
	game.question_handler.login()
	#await game.js_handler.login_successful
	#game.js_handler.find_server("1v1")
func start1v1():
	menu.hide()
	game.show()
	game.show_end("Connecting to 1v1 server...")
	game.find_avail_server("1v1")
	#MultiplayerManager.connect_to_server("127.0.0.1")
	#var success = MultiplayerManager.connect_to_1v1_server()
	#if success:
		#game.show_end("Waiting for player 2...")
	#else:
		#game.show_end("Failed to connect to server, please try again. Returning to main menu")
		#await get_tree().create_timer(5).timeout
		#game.hide()
		#menu.show()
