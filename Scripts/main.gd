extends Node2D

@onready var maze = $Maze
@onready var player = $Player

func _ready() -> void:
	player.set_maze_scale(maze.scale.x)
	player.set_pos(maze.walls.start_coord["row"], maze.walls.start_coord["col"])
	player.set_offset(maze.position)
	player.set_grid(maze.walls.grid)
	player.teleport()
