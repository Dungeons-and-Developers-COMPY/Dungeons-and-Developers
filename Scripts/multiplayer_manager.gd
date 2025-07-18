extends Node

func start_server(port: int = 12345):
	var peer = ENetMultiplayerPeer.new()
	var result = peer.create_server(port, 2)
	if result != OK:
		push_error("Server failed to start.")
		return
	multiplayer.multiplayer_peer = peer
	print("Dedicated server started on port", port)

func connect_to_server(ip: String, port: int = 12345):
	var peer = ENetMultiplayerPeer.new()
	var result = peer.create_client(ip, port)
	if result != OK:
		push_error("Client failed to connect.")
		return
	multiplayer.multiplayer_peer = peer
	print("Connected to server")
