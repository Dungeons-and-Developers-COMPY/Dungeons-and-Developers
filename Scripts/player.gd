extends Node2D
class_name Player

var pos: Vector2i = Vector2i(0, 0)
var maze_scale = 1
var pixels = 16
var offset: Vector2 = Vector2(0, 0)
var grid = []
var valid_funcs = ["move_up", "move_down", "move_left", "move_right"]

const SC = "extends Player\nfunc update_grid(new_grid): grid = new_grid\nfunc execute():\n"

@onready var char = $CharacterBody2D

# functions to move that player can type
func move_left(n: int = 1):
	for i in range(n):
		await try_move(pos.x - 1, pos.y)
	
func move_right(n: int = 1):
	for i in range(n):
		await try_move(pos.x + 1, pos.y)
	
func move_up(n: int = 1):
	for i in range(n):
		await try_move(pos.x, pos.y - 1)
	
func move_down(n: int = 1):
	for i in range(n):
		await try_move(pos.x, pos.y + 1)

# function to move player to the grid coordinate
func move():
	var x = (pos.x * maze_scale * pixels) + (offset.x + pixels)
	var y = (pos.y * maze_scale * pixels) + (offset.y + pixels)
	char.set_target_pos(x, y)
	await char.stopped_moving

# function that attempts to move player, if player can't move, player must get stunned
func try_move(x: int, y: int):
	if (can_move(x, y)):
		pos.x = x
		pos.y = y
		await move()
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
	
# function to execute player-typed movement
func execute_move(code: String):
	var lines = code.split("\n")
	
	for line in lines:
		line = line.strip_edges()
		if line == "":
			continue
		
		var function_name = ""
		var arg = 1
		
		# Simple parsing for calls like move_left(3) or move_down()
		var regex = RegEx.new()
		regex.compile(r"(\w+)\s*\(?(\d*)\)?")
		
		var result = regex.search(line)
		if result:
			function_name = result.get_string(1)
			var arg_str = result.get_string(2)
			if arg_str != "":
				arg = int(arg_str)
			
			if function_name in valid_funcs: # only allows the move functions to be called
				print(function_name)
				await call(function_name, arg)
			else:
				print("Unknown function: %s" % function_name)
		else:
			print("Invalid syntax: %s" % line)
	
