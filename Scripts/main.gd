extends Node2D

@onready var maze = $Maze
@onready var player = $Player
@onready var code_interface = $CodeInterface
@onready var opponent = $GhostPlayer
@onready var end_label = $EndLabel
@onready var question_handler = $QuestionHandler
@onready var js_handler = $JSHandler

var monster_positions = []
var monsters = []
var grid = []

var maze_seed: int
var connected_players: Array = []
var is_server := OS.has_feature("dedicated_server")
var is_game_over: bool = false
var difficulties = ["Easy", "Medium", "Hard"]
var current_question: int = 0

var shutdown_check_timer = 0.0
var game_started = false

#region built-in functions

# called when the node enters the scene tree for the first time
# checks if server or not and starts game 
func _ready() -> void:
	if is_server:
		question_handler.login()
		Globals.server_ip = await MultiplayerManager.get_public_ip()
		Globals.server_port = MultiplayerManager.start_1v1_server()
		connect_server_signals()
		question_handler.register_server(Globals.server_ip, Globals.server_port, "1v1", 2)
	else:
		connect_player_signals()
		if DisplayServer.get_name() != "web":
			question_handler.login()
		show_end("Waiting for player 2...")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		question_handler.deregister_server(Globals.server_ip, Globals.server_port)
		await question_handler.shutdown

func _process(delta: float) -> void:
	if Input.is_action_just_released("attack") and player.should_stop == true:
		player.on_monster_defeated()
		code_interface.defeated_monster()
		code_interface.output_to_console("Monster defeated! Moving enabled.")
		code_interface.output_to_console(Globals.break_string)
	# temp way to shutdown server
	if (is_server):
		shutdown_check_timer += delta
		if shutdown_check_timer >= 2.0:
			shutdown_check_timer = 0
			if FileAccess.file_exists("shutdown.txt"):
				print("Shutdown signal file found.")
				question_handler.deregister_server(Globals.server_ip, Globals.server_port)
				await question_handler.shutdown
				get_tree().quit()

#endregion

#region game setup

func login(next_step: String):
	js_handler.login(next_step)

func find_server():
	find_avail_server("1v1")

func find_avail_server(type: String):
	#question_handler.find_server(type)
	js_handler.find_server(type)

func server_found(found: bool, message: String, ip: String, port: int):
	if found:
		MultiplayerManager.connect_to_server(ip, port)
		show_end("Waiting for player 2...")
	else:
		pass

func connect_player_signals():
	code_interface.run_button_pressed.connect(run_user_code)
	code_interface.test.connect(login)
	code_interface.submit_button_pressed.connect(login)
	player.defeat_monster.connect(monster_defeated)
	player.hit_monster.connect(show_question)
	player.reached_exit.connect(player_won)
	player.moving.connect(opponent_moving)
	player.console.connect(output_to_console)
	player.stunned.connect(stun_player)
	player.end_stun.connect(unstun_player)
	player.moved.connect(check_overlap)
	player.adjust_monster.connect(adjust_monster)
	player.recentre.connect(unspace_player)
	opponent.moved.connect(check_overlap)
	opponent.recentre.connect(unspace_player)
	question_handler.submission_result.connect(receive_submission_feedback)
	question_handler.test_result.connect(receive_test_feedback)
	question_handler.server.connect(server_found)
	
	if OS.get_name() == "Web":
		js_handler.login_successful.connect(execute_next_step)
		js_handler.server.connect(server_found)
		js_handler.submission_result.connect(receive_submission_feedback)
		js_handler.test_result.connect(receive_test_feedback)

func connect_server_signals():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	question_handler.question.connect(receive_question)

# function used by clients to setup the maze
func spawn_maze_and_monsters(grid, monster_pos, monster_types, start_coord, exit_coord, questions, boss):
	hide_end()
	code_interface.set_moving()
	maze.set_maze(grid, start_coord, exit_coord)
	monster_positions = monster_pos
	Globals.monster_positions = monster_positions
	Globals.monster_types = monster_types
	Globals.offset = maze.position
	Globals.maze_scale = maze.scale.x
	Globals.questions = questions
	Globals.boss = boss
	
	player.set_pos(maze.walls.start_coord["row"], maze.walls.start_coord["col"])
	player.set_end_pos(maze.walls.exit_coord["row"], maze.walls.exit_coord["col"])
	player.set_grid(maze.walls.grid)
	player.teleport()
	
	opponent.set_pos(maze.walls.start_coord["row"], maze.walls.start_coord["col"])
	opponent.teleport()
	
	spawn_all_monsters()
	var boss_pos: Vector2i = Vector2i(maze.walls.exit_coord["row"], maze.walls.exit_coord["col"]) 
	spawn_boss(boss_pos)
	player.set_monster_positions(monster_positions)
	space_players()

# function used by clients to spawn all the monsters in
func spawn_all_monsters():
	print(monster_positions)
	for i in range(Globals.num_monsters):
		spawn_monster(monster_positions[i], Globals.monster_types[i])

# function used by server to randomise the monsters spawned
func get_random_monster():
	return randi_range(0, Globals.monsters.size() - 1)

func get_random_boss():
	return randi_range(0, Globals.bosses.size() - 1)

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

func spawn_boss(pos: Vector2i, boss_type: int = 0):
	var x = (pos.x * Globals.maze_scale * Globals.pixels) + (Globals.offset.x + (Globals.pixels / 2 * Globals.maze_scale))
	var y = (pos.y * Globals.maze_scale * Globals.pixels) + (Globals.offset.y + (Globals.pixels / 2 * Globals.maze_scale))
	var actual_pos = Vector2i(x, y)
	
	var boss_scene = Globals.bosses[Globals.boss]
	var boss = boss_scene.instantiate()
	boss.global_position = actual_pos
	boss.scale = Vector2(Globals.bosses_scales[boss_type], Globals.bosses_scales[boss_type])
	add_child(boss)
	monsters.append(boss)

# function called by server when 2 players have entered the server to start the game
func start_game():
	game_started = true
	print()
	print("Starting game...")
	question_handler.get_all_questions()
	await question_handler.all_received
	
	var maze_grid = maze.get_maze()
	var start_coord = maze.get_start()
	var exit_coord = maze.get_exit()
	monster_positions = MazeLogic.get_monster_positions(Globals.num_monsters)
	print("Monsters at positions: " + str(monster_positions))
	Globals.monster_positions = monster_positions
	for i in range(Globals.num_monsters):
		var type = get_random_monster()
		if i > 0:
			while (type == Globals.monster_types[i - 1]):
				type = get_random_monster()
		Globals.monster_types.append(type)
	var monster_types = Globals.monster_types
	Globals.boss = get_random_boss()
	
	for peer_id in connected_players:
		print(Globals.questions.size())
		rpc_id(peer_id, "receive_maze", maze_grid, monster_positions, monster_types, start_coord, exit_coord, Globals.questions, Globals.boss)

#endregion

#region server functions

# function that triggers when a player joins the server
func _on_player_connected(id: int):
	#if connected_players.size() >= 2:
		#rpc_id(id, "reject_connection", "Server Full")
		#return
	print("Player connected: ", id)
	if (connected_players.size() < 2):
		connected_players.append(id)
		question_handler.update_player_count(Globals.server_ip, Globals.server_port, connected_players.size())
		if connected_players.size() == 2:
			start_game()

func _on_player_disconnected(id: int):
	#TODO: end/pause game, call decrease player count on server & remove player from server
	connected_players.erase(id)
	MultiplayerManager.dec_player_count(Globals.server_ip, Globals.server_port)
	if game_started and connected_players.is_empty():
		reset_server()

func reset_server():
	print("Server reset")
	#for id in connected_players:
		#rpc_id(id, "disconnect_from_server")
	#connected_players.clear()
	monster_positions = []
	monsters = []
	grid = []
	Globals.questions = []
	Globals.monster_positions = []
	Globals.monster_types = []
	game_started = false
	is_game_over = false

func disconnect_all_players():
	print("Game over, disconnecting all players")
	for id in connected_players:
		rpc_id(id, "disconnect_from_server")

#endregion

#region rpcs

# rpc function called by server to pass the variables needed by clients to setup the maze
@rpc("authority", "call_remote", "reliable")
func receive_maze(maze, monster_pos, monster_types, start_coord, exit_coord, questions, boss):
	spawn_maze_and_monsters(maze, monster_pos, monster_types, start_coord, exit_coord, questions, boss)

@rpc("authority", "call_remote", "reliable")
func disconnect_from_server():
	MultiplayerManager.disconnect_from_server()
	if DisplayServer.get_name() == "web":
		JavaScriptBridge.eval("window.location.href = 'https://dungeonsanddevelopers.cs.uct.ac.za';")

@rpc("any_peer", "call_remote", "reliable")
func update_opponent_position(pos: Vector2i):
	print("updating opponent position")
	opponent.update_position(pos)

@rpc("any_peer", "call_remote", "reliable")
func game_over(peer_id: int):
	if not is_game_over:
		is_game_over = true
		rpc("announce_winner", peer_id)
		await get_tree().create_timer(2.0).timeout
		if is_server:
			disconnect_all_players()

@rpc("any_peer", "call_remote", "reliable")
func announce_winner(peer_id: int):
	if multiplayer.get_unique_id() == peer_id:
		print("YOU WON!")
		show_end("YOU WON!")
	else:
		print("YOU LOST.")
		show_end("YOU LOST.")

#endregion

#region player functions

func opponent_moving():
	print("received signal")
	print(MultiplayerManager.get_other_peer())
	rpc_id(MultiplayerManager.get_other_peer(), "update_opponent_position", player.pos)

# function called when a player wins (reaches exit and defeats the boss)
func player_won():
	#print("PLAYER WINS")
	rpc_id(1, "game_over", multiplayer.get_unique_id())
	#code_interface.disable_code()

func output_to_console(text: String):
	code_interface.output_to_console(text)

func stun_player():
	code_interface.disable_code()

func unstun_player():
	code_interface.enable_code()

func check_overlap():
	if player.pos == opponent.pos:
		space_players()

func unspace_player(player_num: int):
	if player.pos == opponent.pos:
		if (player_num == 1):
			player.move()
		else:
			opponent.move()

func space_players():
	var x = player.char.global_position.x - (Globals.player_offset * Globals.maze_scale)
	player.char.set_target_pos(x, player.char.global_position.y)
	x = opponent.char.global_position.x + (Globals.player_offset * Globals.maze_scale)
	opponent.char.set_target_pos(x, opponent.char.global_position.y)

#endregion

#region monster functions

func adjust_monster(index: int):
	if index == Globals.num_monsters: 
		var x = player.char.global_position.x - (Globals.boss_offset * Globals.maze_scale)
		player.char.set_target_pos(x, player.char.global_position.y)
		var monster = monsters[index]
		monster.global_position.x = monster.global_position.x + (Globals.boss_offset * Globals.maze_scale)
	else:
		var x = player.char.global_position.x - (Globals.player_offset * Globals.maze_scale)
		player.char.set_target_pos(x, player.char.global_position.y)
		var monster = monsters[index]
		monster.global_position.x = monster.global_position.x + (Globals.player_offset * Globals.maze_scale)
	
	await player.char.stopped_moving
	player.char.animator.flip_h = false

func monster_attack():
	var player_pos = player.pos
	
	var boss = monsters[Globals.monster_positions.size()]
	if (player_pos == Vector2i(maze.walls.exit_coord["row"], maze.walls.exit_coord["col"])):
		if boss.has_method("attack"):
			boss.attack()
		return
	
	for i in range(Globals.monster_positions.size()):
		print(i)
		print(Globals.monster_positions[i])
		if (Globals.monster_positions[i] == player_pos):
			print("monster found")
			var monster = monsters[i]
			if monster.has_method("attack"):
				monster.attack()
				
			break

# function to kill off a monster defeated by a player
func monster_defeated():
	player.attack()
	code_interface.set_moving()
	var player_pos = player.pos
	
	var boss = monsters[Globals.monster_positions.size()]
	if (player_pos == Vector2i(maze.walls.exit_coord["row"], maze.walls.exit_coord["col"])):
		if boss.has_method("die"):
			print("boss dead")
			boss.die()
		return
	
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

#endregion

#region question & code functions

# function used by clients to execute the code entered by the user
func run_user_code():
	print("SIGNAL RECEIVED")
	player.execute_move(code_interface.code)

func receive_question(q):
	Globals.questions.append(q)
	print(q[0])
	print(q[1])

func show_question(question_num: int):
	code_interface.hit_monster()
	var question_data = Globals.questions[question_num]
	current_question = question_data[2]
	print("Current question set to ", current_question)
	code_interface.show_question(question_data[0], question_data[1])

func test_user_code():
	if OS.get_name() == "Web":
		js_handler.test_code(code_interface.code, code_interface.input)
	else:
		question_handler.test_code(code_interface.code, code_interface.input)

func submit_code():
	if OS.get_name() == "Web":
		js_handler.submit_code(current_question, code_interface.code)
	else:
		question_handler.submit_answer(current_question, code_interface.code)

func receive_submission_feedback(output: String, passed: bool):
	code_interface.output_to_console(output)
	if passed:
		player.on_monster_defeated()
		code_interface.defeated_monster()
		code_interface.output_to_console("Monster defeated! Moving enabled.")
		code_interface.output_to_console(Globals.break_string)
	else:
		code_interface.num_submissions += 1
		if code_interface.num_submissions == 3:
			code_interface.enable_new_question()
		monster_attack()
		player.stun()

func receive_test_feedback(output: String, passed: bool):
	if passed:
		code_interface.output_to_console("Compilation finished with no errors!\nOutput of function:")
		code_interface.output_to_console(output)
		code_interface.output_to_console(Globals.break_string)
	else:
		code_interface.output_to_console("Compilation failed! Error:")
		code_interface.output_to_console(output)     
		code_interface.output_to_console(Globals.break_string)      

#endregion

#region helpers

func execute_next_step(next_step: String):
	match next_step:
		"FIND":
			find_server()
		"SUBMIT":
			submit_code()
		"TEST":
			test_user_code()

func show_end(text):
	code_interface.disable_code()
	player.should_stop = true
	end_label.text = text
	end_label.show()
	
func hide_end():
	code_interface.enable_code()
	player.should_stop = false
	end_label.hide()

#endregion
