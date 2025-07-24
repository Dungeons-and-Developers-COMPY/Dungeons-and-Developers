extends Node2D

@onready var maze = $Maze
@onready var player = $Player
@onready var code_interface = $CodeInterface
@onready var opponent = $GhostPlayer
@onready var end_label = $EndLabel

var monster_positions = []
var monsters = []
var grid = []

var maze_seed: int
var connected_players: Array = []
var is_server := OS.has_feature("dedicated_server")
var is_game_over: bool = false

# called when the node enters the scene tree for the first time
# checks if server or not and starts game 
func _ready() -> void:
	if is_server:
		MultiplayerManager.start_server()
		multiplayer.peer_connected.connect(_on_player_connected)
	else:
		code_interface.run_button_pressed.connect(run_user_code)
		player.defeat_monster.connect(monster_defeated)
		player.reached_exit.connect(player_won)
		player.moving.connect(opponent_moving)
		MultiplayerManager.connect_to_server("127.0.0.1")
	
# function used by clients to setup the maze
func spawn_maze_and_monsters(grid, monster_pos, monster_types, start_coord, exit_coord):
	maze.set_maze(grid, start_coord, exit_coord)
	monster_positions = monster_pos
	Globals.monster_positions = monster_positions
	Globals.monster_types = monster_types
	Globals.offset = maze.position
	Globals.maze_scale = maze.scale.x
	
	player.set_pos(maze.walls.start_coord["row"], maze.walls.start_coord["col"])
	player.set_end_pos(maze.walls.exit_coord["row"], maze.walls.exit_coord["col"])
	player.set_grid(maze.walls.grid)
	player.teleport()
	
	opponent.set_pos(maze.walls.start_coord["row"], maze.walls.start_coord["col"])
	opponent.teleport()
	
	spawn_all_monsters()
	player.set_monster_positions(monster_positions)
	
# function used by clients to execute the code entered by the user
func run_user_code():
	print("SIGNAL RECEIVED")
	player.execute_move(code_interface.code)
	
# function used by clients to spawn all the monsters in
func spawn_all_monsters():
	print(monster_positions)
	for i in range(Globals.num_monsters):
		spawn_monster(monster_positions[i], Globals.monster_types[i])
	
# function used by server to randomise the monsters spawned
func get_random_monster():
	return randi_range(0, Globals.monsters.size() - 1)
	
# function used by clients to set a monster to its correct position
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
	
# function to kill off a monster defeated by a player
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

# function that triggers when a player joins the server
func _on_player_connected(id: int):
	print("Player connected: ", id)
	connected_players.append(id)
	if connected_players.size() == 2:
		start_game()
		
# function called by server when 2 players have entered the server to start the game
func start_game():
	var maze_grid = maze.get_maze()
	var start_coord = maze.get_start()
	var exit_coord = maze.get_exit()
	monster_positions = MazeLogic.get_monster_positions(Globals.num_monsters)
	Globals.monster_positions = monster_positions
	for i in range(Globals.num_monsters):
		Globals.monster_types.append(get_random_monster())
	var monster_types = Globals.monster_types
	for peer_id in connected_players:
		rpc_id(peer_id, "receive_maze", maze_grid, monster_positions, monster_types, start_coord, exit_coord)
		
# rpc function called by server to pass the variables needed by clients to setup the maze
@rpc("authority")
func receive_maze(maze, monster_pos, monster_types, start_coord, exit_coord):
	spawn_maze_and_monsters(maze, monster_pos, monster_types, start_coord, exit_coord)
	
@rpc("any_peer", "call_remote")
func update_opponent_position(pos: Vector2i):
	print("updating opponent position")
	opponent.update_position(pos)

func opponent_moving():
	print("received signal")
	print(MultiplayerManager.get_other_peer())
	rpc_id(MultiplayerManager.get_other_peer(), "update_opponent_position", player.pos)

# function called when a player wins (reaches exit and defeats the boss)
func player_won():
	#print("PLAYER WINS")
	rpc_id(1, "game_over", multiplayer.get_unique_id())
	#code_interface.disable_code()

@rpc("any_peer")
func game_over(peer_id: int):
	if not is_game_over:
		is_game_over = true
		rpc("announce_winner", peer_id)
	
@rpc("any_peer")
func announce_winner(peer_id: int):
	if multiplayer.get_unique_id() == peer_id:
		print("YOU WON!")
		show_end("YOU WON!")
	else:
		print("YOU LOST.")
		show_end("YOU LOST.")
	
func show_end(text):
	code_interface.disable_code()
	player.should_stop = true
	end_label.text = text
	end_label.show()
