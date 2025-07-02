extends Node2D

var pos: Vector2i = Vector2i(0, 0)
var maze_scale = 1
var pixels = 16
var offset: Vector2 = Vector2(0, 0)
var grid = []

@onready var char = $CharacterBody2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		try_move(pos.x + 1, pos.y)
	if event.is_action_pressed("ui_left"):
		try_move(pos.x - 1, pos.y)
	if event.is_action_pressed("ui_down"):
		try_move(pos.x, pos.y + 1)
	if event.is_action_pressed("ui_up"):
		try_move(pos.x, pos.y - 1)
	
func set_pos(x: int, y: int):
	pos.x = x
	pos.y = y
	
func try_move(x: int, y: int):
	if (can_move(x, y)):
		pos.x = x
		pos.y = y
		move()
	# TODO: else stun player

func can_move(x: int, y: int):
	if grid[x][y] == 1:
		return false
	else:
		return true
	
func teleport():
	var x_pos = (pos.x * maze_scale * pixels) + (offset.x + pixels)
	var y_pos = (pos.y * maze_scale * pixels) + (offset.y + pixels)
	char.global_position = Vector2(x_pos, y_pos)

func set_offset(pos: Vector2):
	offset = pos

func set_maze_scale(s):
	maze_scale = s
	
func set_grid(g):
	grid = g
	print_grid()
	
func move():
	var x = (pos.x * maze_scale * pixels) + (offset.x + pixels)
	var y = (pos.y * maze_scale * pixels) + (offset.y + pixels)
	char.set_target_pos(x, y)
	
func print_grid():
	print("Grid on player")
	var row: String = ""
	for y in range(Globals.grid_size):
		for x in range(Globals.grid_size):
			row = row + str(grid[x][y]) 
		print(row)
		row = ""
