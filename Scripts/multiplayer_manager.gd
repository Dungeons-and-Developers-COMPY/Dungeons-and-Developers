extends Node

func start_1v1_server(starting_port: int = 12345, max_servers: int = 5):
	for i in range(max_servers):
		var success = start_server(starting_port + i)
		if success:
			return
	push_error("1v1 server could not start on any ports")

func start_2v2_server(starting_port: int = 12345, max_servers: int = 5):
	for i in range(max_servers):
		var success = start_server(starting_port + i)
		if success:
			return
	push_error("2v2 server could not start on any ports")

func start_server(port: int = 12345):
	var peer = ENetMultiplayerPeer.new()
	var result = peer.create_server(port, 2)
	if result != OK:
		if result == ERR_ALREADY_IN_USE:
			print("Port ", port, " already in use. Trying different port...")
		else:
			push_error("Server failed to start.")
		return false
	multiplayer.multiplayer_peer = peer
	print("Dedicated server started on port: ", port)
	return true

func connect_to_1v1_server():
	for i in range(Globals.ports_1v1.size()):
		var success = connect_to_server(Globals.local_ip, Globals.ports_1v1[i])
		if success:
			return true
	push_error("Failed to connect to any 1v1 server")
	return false

func connect_to_server(ip: String, port: int = 12345):
	var peer = ENetMultiplayerPeer.new()
	var result = peer.create_client(ip, port)
	if result != OK:
		push_error("Client failed to connect.")
		return false
	
	multiplayer.multiplayer_peer = peer
	print("Connected to server on port: ", port)
	
func get_other_peer():
	print(multiplayer.get_peers())
	for peer_id in multiplayer.get_peers():
		if peer_id != multiplayer.get_unique_id() and peer_id != 1:
			return peer_id
	return 1
