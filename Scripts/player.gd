extends Node2D
class_name Player

var end_pos: Vector2i = Vector2i(0, 0) # position of exit
var pos: Vector2i = Vector2i(0, 0) # player's current position
var grid = [] 
var valid_funcs = ["move_up", "move_down", "move_left", "move_right"]
var should_stop: bool = false
var monster_positions = []
var monsters_status = []

signal hit_monster
signal defeat_monster
signal reached_exit
signal moving
signal console(text: String)
signal stunned
signal end_stun

@onready var char = $CharacterBody2D

func _process(_delta: float) -> void:
	if Input.is_action_just_released("attack") and should_stop == true:
		on_monster_defeated()

# functions to move that player can type
func move_left(n: int = 1):
	for i in range(n):
		if should_stop:
			break
		await try_move(pos.x - 1, pos.y)
	
func move_right(n: int = 1):
	for i in range(n):
		if should_stop:
			break
		await try_move(pos.x + 1, pos.y)
	
func move_up(n: int = 1):
	for i in range(n):
		if should_stop:
			break
		await try_move(pos.x, pos.y - 1)
	
func move_down(n: int = 1):
	for i in range(n):
		if should_stop:
			break
		await try_move(pos.x, pos.y + 1)

# function to move player to the grid coordinate
func move():
	emit_signal("moving")
	var x = (pos.x * Globals.maze_scale * Globals.pixels) + (Globals.offset.x + (Globals.pixels / 2 * Globals.maze_scale))
	var y = (pos.y * Globals.maze_scale * Globals.pixels) + (Globals.offset.y + (Globals.pixels / 2 * Globals.maze_scale))
	char.set_target_pos(x, y)
	await char.stopped_moving
	var string = "Moved to position " + str(pos)
	emit_signal("console", string)

# function that attempts to move player, if player can't move, player must get stunned
func try_move(x: int, y: int):
	if (can_move(x, y)):
		pos.x = x
		pos.y = y
		if (on_monster_coord()):
			should_stop = true
			emit_signal("hit_monster")
			emit_signal("console", "There's a monster blocking your path... Stopping movement")
		if (has_reached_exit()):
			should_stop = true
			emit_signal("reached_exit")
		await move()
	else:
		emit_signal("console", "Wall hit! Stunning for " + str(Globals.stun_time) + " seconds")
		await stun()
		#await get_tree().create_timer(Globals.stun_time).timeout
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
	var x_pos = (pos.x * Globals.maze_scale * Globals.pixels) + (Globals.offset.x + (Globals.pixels / 2 * Globals.maze_scale))
	var y_pos = (pos.y * Globals.maze_scale * Globals.pixels) + (Globals.offset.y + (Globals.pixels / 2 * Globals.maze_scale))
	char.global_position = Vector2(x_pos, y_pos)

# set fuctions for variables
func set_pos(x: int, y: int):
	pos.x = x
	pos.y = y
	
func set_grid(g):
	grid = g

func set_end_pos(x: int, y: int):
	end_pos = Vector2i(x, y)
	
func set_monster_positions(array):
	monster_positions = array
	for i in range(monster_positions.size()):
		monsters_status.append(1)
	
# function to execute player-typed movement
func execute_move(code: String):
	var lines = code.split("\n")
	
	for line in lines:
		if should_stop:
			break
			
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
	
# checks if player is on same block as a monster
func on_monster_coord():
	for i in range(monster_positions.size()):
		if pos == monster_positions[i] and monsters_status[i] == 1:
			return true
			
	return false
	
# called when monster gets killed
func on_monster_defeated():
	for i in range(monster_positions.size()):
		if pos == monster_positions[i]:
			monsters_status[i] = 0
	#monster_positions.pop_front()
	should_stop = false
	emit_signal("defeat_monster")
	
# check if player is on exit block
func has_reached_exit():
	if pos == end_pos:
		return true
	else:
		return false
		
func stun():
	emit_signal("stunned")
	char.stun()
	await get_tree().create_timer(Globals.stun_time).timeout
	emit_signal("end_stun")
