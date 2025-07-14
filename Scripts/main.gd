extends Node2D

@onready var maze = $Maze
@onready var player = $Player
@onready var code_interface = $CodeInterface

func _ready() -> void:
	code_interface.run_button_pressed.connect(run_user_code)
	
	player.set_maze_scale(maze.scale.x)
	player.set_pos(maze.walls.start_coord["row"], maze.walls.start_coord["col"])
	player.set_offset(maze.position)
	player.set_grid(maze.walls.grid)
	player.teleport()
	
func run_user_code():
	print("SIGNAL RECEIVED")
	player.execute_move(code_interface.code)
	
