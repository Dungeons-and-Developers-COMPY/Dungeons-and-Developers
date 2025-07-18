extends Node2D

@onready var maze = $Maze
@onready var player = $Player
@onready var code_interface = $CodeInterface

var monster_positions = []
var monsters = []
var grid = []

var maze_seed: int
var connected_players: Array = []
var is_server := OS.has_feature("dedicated_server")

func _ready() -> void:
	#if is_server:
		#MultiplayerManager.start_server()
		#multiplayer.peer_connected.connect(_on_player_connected)
		#maze.gen_maze()
	#else:
		#code_interface.run_button_pressed.connect(run_user_code)
		#player.defeat_monster.connect(monster_defeated)
		#player.reached_exit.connect(player_won)
	spawn_maze_and_monsters()
	
func spawn_maze_and_monsters():
	RandomNumberGenerator.new().seed = maze_seed
	#randomize()
	maze.gen_maze()
	
	code_interface.run_button_pressed.connect(run_user_code)
	player.defeat_monster.connect(monster_defeated)
	player.reached_exit.connect(player_won)
	
	Globals.offset = maze.position
	Globals.maze_scale = maze.scale.x
	
	#player.set_maze_scale(maze.scale.x)
	player.set_pos(maze.walls.start_coord["row"], maze.walls.start_coord["col"])
	player.set_end_pos(maze.walls.exit_coord["row"], maze.walls.exit_coord["col"])
	player.set_grid(maze.walls.grid)
	player.teleport()
	
	spawn_all_monsters()
	player.set_monster_positions(monster_positions)
	
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
	var x = (pos.x * Globals.maze_scale * Globals.pixels) + (Globals.offset.x + (Globals.pixels / 2 * Globals.maze_scale))
	var y = (pos.y * Globals.maze_scale * Globals.pixels) + (Globals.offset.y + (Globals.pixels / 2 * Globals.maze_scale))
	var actual_pos = Vector2i(x, y)
	
	var monster_scene = Globals.monsters[monster_type]
	var monster = monster_scene.instantiate()
	monster.global_position = actual_pos
	monster.scale = Vector2(Globals.monster_scales[monster_type], Globals.monster_scales[monster_type])
	add_child(monster)
	monsters.append(monster)
	
func monster_defeated():
	print("received monster killed")
	var player_pos = player.pos
	print(player_pos)
	print(Globals.monster_positions)
	for i in range(Globals.monster_positions.size()):
		print(i)
		print(Globals.monster_positions[i])
		if (Globals.monster_positions[i] == player_pos):
			print("monster found")
			var monster = monsters[i]
			if monster.has_method("die"):
				print("monster dead")
				monster.die()
				
			break

func player_won():
	print("PLAYER WINS")
	code_interface.disable_code()
	
	
	
