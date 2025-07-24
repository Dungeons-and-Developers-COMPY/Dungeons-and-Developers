extends Node

func start_server(port: int = 12345):
	var peer = ENetMultiplayerPeer.new()
	var result = peer.create_server(port, 2)
	if result != OK:
		push_error("Server failed to start.")
		return
	multiplayer.multiplayer_peer = peer
	print("Dedicated server started on port: ", port)

func connect_to_server(ip: String, port: int = 12345):
	var peer = ENetMultiplayerPeer.new()
	var result = peer.create_client(ip, port)
	if result != OK:
		push_error("Client failed to connect.")
		return
	multiplayer.multiplayer_peer = peer
	print("Connected to server")
	
func get_other_peer():
	print(multiplayer.get_peers())
	for peer_id in multiplayer.get_peers():
		if peer_id != multiplayer.get_unique_id() and peer_id != 1:
			return peer_id
	return 1
