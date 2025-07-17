extends Node2D

@onready var maze = $Maze
@onready var player = $Player
@onready var code_interface = $CodeInterface

var monster_positions = []

func _ready() -> void:
	randomize()
	code_interface.run_button_pressed.connect(run_user_code)
	
	Globals.offset = maze.position
	Globals.maze_scale = maze.scale.x
	
	#player.set_maze_scale(maze.scale.x)
	player.set_pos(maze.walls.start_coord["row"], maze.walls.start_coord["col"])
	#player.set_offset(maze.position)
	player.set_grid(maze.walls.grid)
	player.teleport()
	
	spawn_all_monsters()
	
func run_user_code():
	print("SIGNAL RECEIVED")
	player.execute_move(code_interface.code)
	
	
func spawn_all_monsters():
	monster_positions = MazeLogic.get_monster_positions(Globals.num_monsters)
	Globals.monster_positions = monster_positions
	print(monster_positions)
	for i in range(Globals.num_monsters):
		spawn_monster(monster_positions[i], get_random_monster())
	
func get_random_monster():
	return randi_range(0, Globals.monsters.size() - 1)
	
func spawn_monster(pos: Vector2i, monster_type: int):
	var x = (pos.x * Globals.maze_scale * Globals.pixels) + (Globals.offset.x + Globals.pixels)
	var y = (pos.y * Globals.maze_scale * Globals.pixels) + (Globals.offset.y + Globals.pixels)
	var actual_pos = Vector2i(x, y)
	
	var monster_scene = Globals.monsters[monster_type]
	var monster = monster_scene.instantiate()
	monster.global_position = actual_pos
	monster.scale = Vector2(Globals.monster_scales[monster_type], Globals.monster_scales[monster_type])
	add_child(monster)
	
	
