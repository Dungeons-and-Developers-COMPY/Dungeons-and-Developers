extends Node2D

var pos: Vector2i = Vector2i(0, 0) # player's current position

@onready var char = $CharacterBody2D

func _ready() -> void:
	modulate = Color(1.5, 0.5, 0.5)

func update_position(grid_pos: Vector2i):
	pos = grid_pos
	move()

func set_pos(x: int, y: int):
	pos.x = x
	pos.y = y

# function to move player to its current position without movement 
func teleport():
	var x_pos = (pos.x * Globals.maze_scale * Globals.pixels) + (Globals.offset.x + (Globals.pixels / 2 * Globals.maze_scale))
	var y_pos = (pos.y * Globals.maze_scale * Globals.pixels) + (Globals.offset.y + (Globals.pixels / 2 * Globals.maze_scale))
	char.global_position = Vector2(x_pos, y_pos)

# function to move player to the grid coordinate
func move():
	var x = (pos.x * Globals.maze_scale * Globals.pixels) + (Globals.offset.x + (Globals.pixels / 2 * Globals.maze_scale))
	var y = (pos.y * Globals.maze_scale * Globals.pixels) + (Globals.offset.y + (Globals.pixels / 2 * Globals.maze_scale))
	char.set_target_pos(x, y)
	await char.stopped_moving
