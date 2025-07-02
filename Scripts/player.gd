extends Node2D

var pos: Vector2i = Vector2i(0, 0)
var maze_scale = 1
var pixels = 16
var offset: Vector2 = Vector2(0, 0)
var grid = []

@onready var char = $CharacterBody2D

# input function for movement
# TODO: replace with code based movement
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		try_move(pos.x + 1, pos.y)
	if event.is_action_pressed("ui_left"):
		try_move(pos.x - 1, pos.y)
	if event.is_action_pressed("ui_down"):
		try_move(pos.x, pos.y + 1)
	if event.is_action_pressed("ui_up"):
		try_move(pos.x, pos.y - 1)

# function that attempts to move player, if player can't move, player must get stunned
func try_move(x: int, y: int):
	if (can_move(x, y)):
		pos.x = x
		pos.y = y
		move()
	# TODO: else stun player

# function to check if the player can move to that position
func can_move(x: int, y: int):
	if (x >= Globals.grid_size) or (x < 0):
		return false
	if (y >= Globals.grid_size) or (y < 0):
		return false
	if grid[x][y] == 1:
		return false
	else:
		return true

# function to move player to its current position without movement 
func teleport():
	var x_pos = (pos.x * maze_scale * pixels) + (offset.x + pixels)
	var y_pos = (pos.y * maze_scale * pixels) + (offset.y + pixels)
	char.global_position = Vector2(x_pos, y_pos)

# set fuctions for variables
func set_pos(x: int, y: int):
	pos.x = x
	pos.y = y
func set_offset(pos: Vector2):
	offset = pos
func set_maze_scale(s):
	maze_scale = s
func set_grid(g):
	grid = g
	
# function to move player to the grid coordinate
func move():
	var x = (pos.x * maze_scale * pixels) + (offset.x + pixels)
	var y = (pos.y * maze_scale * pixels) + (offset.y + pixels)
	char.set_target_pos(x, y)
