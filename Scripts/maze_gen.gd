extends TileMapLayer
class_name MazeGen

var starting_pos = Vector2i()
const main_layer = 0
const normal_wall_atlas_coords = Vector2i(0, 1)
const walkable_atlas_coords = Vector2i(9, 4)
const SOURCE_ID = 2
# binary rep of all possbile wall combinations
var wall_type_atlas_coords = {
	0b0000: Vector2i(0, 1), # isolated
	0b0001: Vector2i(3, 3), # left only
	0b0010: Vector2i(1, 3), # right only
	0b0011: Vector2i(2, 3), # horizontal
	0b0100: Vector2i(0, 2), # up only
	0b0101: Vector2i(3, 2), # up and left
	0b0110: Vector2i(1, 2), # up and right
	0b0111: Vector2i(2, 2), # horizontal and up
	0b1000: Vector2i(0, 0), # down only
	0b1001: Vector2i(3, 0), # down and left
	0b1010: Vector2i(1, 0), # down and right
	0b1011: Vector2i(2, 0), # horizontal and down
	0b1100: Vector2i(0, 1), # vertical
	0b1101: Vector2i(3, 1), # vertical and left
	0b1110: Vector2i(1, 1), # vertical and right
	0b1111: Vector2i(2, 1), # all 4
}
# assign unique bit to each dir using bit shifting
const LEFT  = 1 << 0  # 0001
const RIGHT = 1 << 1  # 0010
const UP    = 1 << 2  # 0100
const DOWN  = 1 << 3  # 1000

var spot_to_letter = {}
var spot_to_label = {}
var current_letter_num = 65
#const label = preload("res://simple_label.tscn")
var start_coord = null
var exit_coord = null

@export var y_dim = 35
@export var x_dim = 35
@export var starting_coords = Vector2i(0, 0)
var adj4 = [
	Vector2i(-1, 0),
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1),
]

var grid = []

func _process(delta: float) -> void:
	if Input.is_action_just_released("ui_accept"):
		print_grid()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# init grid
	#grid.resize(Globals.grid_size * Globals.grid_size)
	#grid.fill(0)
	for i in range(Globals.grid_size):
		grid.append([])
		for j in range(Globals.grid_size):
			grid[i].append(0)
	
	y_dim = Globals.grid_size
	x_dim = Globals.grid_size
	#starting_coords = Vector2i(x_dim/2,y_dim/2)
	Globals.letters_to_show.clear()
	#place_border()
	dfs(starting_coords)
	get_start()
	print_grid()
	
	for y in range(Globals.grid_size):
		for x in range(Globals.grid_size):
			if grid[x][y] == 1:
				print(x, " ", y)
				set_wall_tile(x, y)
	

func _input(event: InputEvent) -> void:
	pass
#	if Input.is_action_just_pressed("reset"):
#		get_tree().reload_current_scene()
	
	
func place_border():
	for y in range(-1, y_dim):
		place_wall(Vector2(-1, y))
	for x in range(-1, x_dim):
		place_wall(Vector2(x, -1))
	for y in range(-1, y_dim + 1):
		place_wall(Vector2(x_dim, y))
	for x in range(-1, x_dim + 1):
		place_wall(Vector2(x, y_dim))


func delete_cell_at(pos: Vector2):
	set_cell(pos)
	
	
func place_wall(pos: Vector2):
	set_cell(pos, SOURCE_ID, normal_wall_atlas_coords)
	var x = pos.x
	var y = pos.y
	grid[x][y] = 1
		


func will_be_converted_to_wall(spot: Vector2i):
	return (spot.x % 2 == 1 and spot.y % 2 == 1)
	
	
func is_wall(pos):
	#return get_cell_atlas_coords(main_layer, pos) in [
		#normal_wall_atlas_coords
	#]
	return (grid[pos.x][pos.y] == 1)


func can_move_to(current: Vector2i):
	return (
			current.x >= 0 and current.y >= 0 and\
			current.x < x_dim and current.y < y_dim and\
			not is_wall(current)
	)


func dfs(start: Vector2i):
	var fringe: Array[Vector2i] = [start]
	var seen = {}
	while fringe.size() > 0:
		var current: Vector2i 
		current = fringe.pop_back() as Vector2
		Globals.letters_to_show.pop_front()
		if current in seen or not can_move_to(current):
			if Globals.show_labels and Globals.step_delay > 0:
				await get_tree().create_timer(Globals.step_delay).timeout
			continue
			
		seen[current] = true
		if current in spot_to_label:
			for node in spot_to_label[current]:
				node.queue_free()
##			var existing_letter = find_child(spot_to_letter[current])
#			if existing_letter != null:
#				existing_letter.queue_free()
		if current.x % 2 == 1 and current.y % 2 == 1:
			place_wall(current)
			continue
			
		#set_cell(current, SOURCE_ID, walkable_atlas_coords)
		if Globals.step_delay > 0:
			await get_tree().create_timer(Globals.step_delay).timeout
		
		
		var found_new_path = false
		adj4.shuffle()
		for pos in adj4:
			var new_pos = current + pos
			if new_pos not in seen and can_move_to(new_pos):
				var chance_of_no_loop = randi_range(1, 1)
				if Globals.allow_loops:
					chance_of_no_loop = randi_range(1, 5)
				if will_be_converted_to_wall(new_pos) and chance_of_no_loop == 1:
					place_wall(new_pos)
				else:
					found_new_path = true
					fringe.append(new_pos)
					if Globals.show_labels:
						if new_pos not in spot_to_letter:
							spot_to_letter[new_pos] = char(current_letter_num)
							current_letter_num += 1
						Globals.letters_to_show.push_front(spot_to_letter[new_pos])	
						#place_label(new_pos, spot_to_letter[new_pos])
					
		#if we hit a dead end or are at a cross section
		if not found_new_path:
			place_wall(current)

#func place_label(pos: Vector2i, text: String):
	#var current_label: Label = label.instantiate()
	#current_label.text = text
	#current_label.name = text
	#add_child.call_deferred(current_label)
	#if pos not in spot_to_label:
		#spot_to_label[pos] = []
	#spot_to_label[pos].append(current_label)
	#current_label.position = map_to_local(pos) - (Vector2i(64, 50)  / 2.0)
	

func get_start():
	var result = MazeLogic.find_starting_sqaure(grid, Globals.grid_size)
	if result != null:
		print("Starting square at (", result["row"], ",", result["col"], ")")
	else:
		print("No edge square reachable.")
	set_cell(Vector2i(result["row"],result["col"]), SOURCE_ID, Vector2i(9, 0))
	start_coord = result
	get_exit(result["row"],result["col"])

func get_exit(row: int, col: int):
	var result = MazeLogic.find_furthest_edge_square(grid,row,col)
	if result != null:
		print("Furthest edge square at (", result["row"], ",", result["col"], ") with distance ", result["dist"])
	else:
		print("No edge square reachable.")
	set_cell(Vector2i(result["row"],result["col"]), SOURCE_ID, Vector2i(9, 0))
	exit_coord = result
	grid[result["row"]][result["col"]] = 3
	

func set_wall_tile(x: int, y: int):
	var left: bool = false
	var right: bool = false
	var up: bool = false
	var down: bool = false
	if x == 0:
		left = true
		if grid[x+1][y] == 1:
			right = true
	elif x == (Globals.grid_size - 1):
		right = true
		if grid[x-1][y] == 1:
			left = true
	else:
		if grid[x-1][y] == 1:
			left = true
		if grid[x+1][y] == 1:
			right = true
			
	if y == 0:
		up = true
		if grid[x][y+1] == 1:
			down = true
	elif y == (Globals.grid_size - 1): 
		down = true
		if grid[x][y-1] == 1:
			up = true
	else:
		if grid[x][y-1] == 1:
			up = true
		if grid[x][y+1] == 1:
			down = true
	
	place_wall_texture(left, right, up, down, Vector2i(x, y))

func place_wall_texture(left: bool, right: bool, up: bool, down: bool, coord: Vector2i):
	var index = 0
	if left:
		index |= LEFT
	if right:
		index |= RIGHT
	if up:
		index |= UP
	if down:
		index |= DOWN
		
	var atlas_coord = wall_type_atlas_coords.get(index, normal_wall_atlas_coords) 
	set_cell(coord, SOURCE_ID, atlas_coord)

func print_grid():
	var row: String = ""
	for y in range(Globals.grid_size):
		for x in range(Globals.grid_size):
			row = row + str(grid[x][y]) 
		print(row)
		row = ""
		
	#get_exit()
