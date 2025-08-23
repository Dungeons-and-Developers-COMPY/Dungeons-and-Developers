extends Node

var auth_token: String = ""
var is_authenticated: bool = false

#func _ready():
	# authenticate to access the server list
	#await authenticate_with_api()

#region auth functions

func authenticate_with_api():
	var http = HTTPRequest.new()
	add_child(http)
	
	var login_data = {
		"username": "Mahir",
		"password": "MrMoodles123!"
	}
	
	var json_string = JSON.stringify(login_data)
	var headers = ["Content-Type: application/json"]
	
	print("Authenticating with API...")
	http.request("https://dungeonsanddevelopers.cs.uct.ac.za/admin/login", headers, HTTPClient.METHOD_POST, json_string)
	
	var result = await http.request_completed
	
	if result[0] == OK and result[1] == 200:
		var response_text = result[3].get_string_from_utf8()
		print("Login successful: ", response_text)
		
		# extract session cookie from headers
		var response_headers = result[2]
		for header in response_headers:
			if header.begins_with("Set-Cookie:") and header.contains("remember_token"):
				auth_token = header.split("remember_token=")[1].split(";")[0]
				is_authenticated = true
				print("Auth token extracted: ", auth_token)
				break
		
		if not is_authenticated:
			push_error("Failed to extract authentication token")
	else:
		push_error("Authentication failed. Status: ", result[1])
		print("Response: ", result[3].get_string_from_utf8())
	
	http.queue_free()

func get_auth_headers():
	var headers = ["Content-Type: application/json"]
	if is_authenticated and auth_token != "":
		headers.append("Cookie: remember_token=" + auth_token)
	return headers

#endregion

#region client functions

func connect_to_1v1_server():
	var server_info = await get_available_1v1_server()
	if server_info == null:
		push_error("No 1v1 servers available")
		return false
	
	var success = await connect_to_server(server_info.ip, server_info.port)
	return success

func connect_to_2v2_server():
	var server_info = await get_available_2v2_server()
	if server_info == null:
		push_error("No 2v2 servers available")
		return false
	
	var success = await connect_to_server(server_info.ip, server_info.port)
	return success

func get_available_1v1_server():
	return await get_available_server("1v1")

func get_available_2v2_server():
	return await get_available_server("2v2")

func get_available_server(server_type: String):
	var http = HTTPRequest.new()
	add_child(http)
	
	print("Requesting server list for type: ", server_type)
	
	var headers = get_auth_headers() if is_authenticated else []
	http.request("https://dungeonsanddevelopers.cs.uct.ac.za/server/list", headers)
	
	var result = await http.request_completed
	http.queue_free()
	
	print("Server list response: Status=", result[1], " Body=", result[3].get_string_from_utf8())
	
	if result[0] != OK:
		push_error("Failed to get server list. Network error: ", result[0])
		return null
	
	var response_text = result[3].get_string_from_utf8()
	
	# handle different status codes
	if result[1] == 404:
		print("No servers available (404) for type: ", server_type)
		return null
	elif result[1] != 200:
		push_error("Server list request failed. Status: ", result[1])
		return null
	
	var json = JSON.new()
	var parse_result = json.parse(response_text)
	
	if parse_result != OK:
		push_error("Failed to parse server list JSON: ", response_text)
		return null
	
	var data = json.data
	print("Parsed server data: ", data)
	
	# handle both error responses and success responses
	if data.has("error"):
		print("API returned error: ", data.error)
		return null
	
	if not data.has("servers") or data.servers.size() == 0:
		print("No servers in response")
		return null
	
	# find a server of the requested type with available slots
	for server in data.servers:
		if server.type == server_type and server.current_players < server.max_players:
			print("Found available ", server_type, " server: ", server)
			return server
	
	print("No available ", server_type, " servers with free slots")
	return null

func connect_to_server(ip: String, port: int):
	var peer = WebSocketMultiplayerPeer.new()
	ip = ip.strip_edges()
	
	# connect to the actual game server using discovered IP/port
	var url = "ws://%s:%d" % [ip, port] 
	if ( OS.get_name() == "Web"):
		url = "wss://dungeonsanddevelopers.cs.uct.ac.za/ws/" + str(port) + "/"
	print("Connecting to game server: ", url)
	
	var result = peer.create_client(url)
	if result != OK:
		push_error("Failed to create WebSocket client for: ", url, " Error: ", result)
		return false
	
	multiplayer.multiplayer_peer = peer
	print("WebSocket client created, connecting to: ", url)
	
	# wait for connection to establish
	var timeout = 10.0 
	var elapsed = 0.0
	
	while multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		if elapsed > timeout:
			push_error("Connection timeout to server: ", url)
			return false
	
	var status = multiplayer.multiplayer_peer.get_connection_status()
	if status == MultiplayerPeer.CONNECTION_CONNECTED:
		print("Successfully connected to game server: ", url)
		return true
	else:
		push_error("Failed to connect to game server: ", url, " Status: ", status)
		return false

#endregion

#region utility functions

func get_other_peer():
	var peers = multiplayer.get_peers()
	print("Current peers: ", peers)
	for peer_id in peers:
		if peer_id != multiplayer.get_unique_id() and peer_id != 1:
			return peer_id
	return 1

func disconnect_from_server():
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
		print("Disconnected from server")

func get_connection_status():
	if multiplayer.multiplayer_peer:
		return multiplayer.multiplayer_peer.get_connection_status()
	return MultiplayerPeer.CONNECTION_DISCONNECTED

func get_current_server_info():
	return {
		"connected": get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED,
		"peer_id": multiplayer.get_unique_id(),
		"peers": multiplayer.get_peers(),
		"peer_count": multiplayer.get_peers().size()
	}

#endregion

#region server functions

func start_1v1_server(starting_port: int = 12341, max_servers: int = 5):
	print("Starting 1v1 server...")
	for i in range(max_servers):
		var port = starting_port + i
		var success = start_local_server(port)
		if success:
			print("1v1 server started successfully on port: ", port)
			return port
	push_error("1v1 server could not start on any ports")
	return -1

func start_2v2_server(starting_port: int = 12343, max_servers: int = 5):
	print("Starting 2v2 server...")
	for i in range(max_servers):
		var port = starting_port + i
		var success = start_local_server(port)
		if success:
			print("2v2 server started successfully on port: ", port)
			return port
	push_error("2v2 server could not start on any ports")
	return -1

func start_local_server(port: int):
	var peer = WebSocketMultiplayerPeer.new()
	var result = peer.create_server(port)
	
	if result != OK:
		if result == ERR_ALREADY_IN_USE:
			print("Port ", port, " already in use. Trying different port...")
		else:
			push_error("Server failed to start on port ", port, ". Error: ", result)
		return false
	
	multiplayer.multiplayer_peer = peer
	print("Local WebSocket server started on port: ", port)
	return true

func register_server_with_api(ip: String, port: int, server_type: String = "1v1", max_players: int = 2):
	print("Attempting to register server with API...")
	print("Server details - IP: ", ip, " Port: ", port, " Type: ", server_type)
	
	if not is_authenticated:
		print("Not authenticated - attempting authentication...")
		await authenticate_with_api()
		if not is_authenticated:
			push_error("Failed to authenticate - cannot register server")
			return false
	
	var http = HTTPRequest.new()
	add_child(http)
	
	var registration_data = {
		"ip": ip,
		"port": port,
		"type": server_type,
		"max_players": max_players,
		"current_players": 0
	}
	
	var json_string = JSON.stringify(registration_data)
	var headers = get_auth_headers()
	
	print("Registration data: ", json_string)
	print("Headers: ", headers)
	
	http.request("https://dungeonsanddevelopers.cs.uct.ac.za/server/register", headers, HTTPClient.METHOD_POST, json_string)
	
	var result = await http.request_completed
	http.queue_free()
	
	print("Registration response:")
	print("Status Code: ", result[1])
	print("Response Body: ", result[3].get_string_from_utf8())
	print("Network Error: ", result[0])
	
	if result[0] == OK and (result[1] == 200 or result[1] == 201):
		print("Server successfully registered with API!")
		return true
	else:
		push_error("Failed to register server. Status: ", result[1])
		var response_body = result[3].get_string_from_utf8()
		print("Error details: ", response_body)
		return false

func get_public_ip():
	print("Getting public IP...")
	var http = HTTPRequest.new()
	add_child(http)
	
	var ip_services = [
		"https://ifconfig.me/ip",
	]
	
	for service in ip_services:
		print("Trying IP service: ", service)
		http.request(service)
		var result = await http.request_completed
		
		if result[0] == OK and result[1] == 200:
			var ip = result[3].get_string_from_utf8().strip_edges()
			if ip != "" and ip.is_valid_ip_address():
				print("Public IP: ", ip)
				http.queue_free()
				return ip
		
		print("Failed to get IP from ", service)
		await get_tree().create_timer(1.0).timeout
	
	http.queue_free()
	push_error("Failed to get public IP from any service.")
	return ""
	
func dec_player_count(ip: String, port: int):
	var http = HTTPRequest.new()
	add_child(http)
	
	var data = {
		"ip": ip,
		"port": port
	}
	
	var json_string = JSON.stringify(data)
	var headers = get_auth_headers()
	
	http.request("https://dungeonsanddevelopers.cs.uct.ac.za/server/decrement-players", headers, HTTPClient.METHOD_POST, json_string)
	
	var result = await http.request_completed
	http.queue_free()
	
	print("Decrement player Response:")
	print("Status Code: ", result[1])
	print("Response Body: ", result[3].get_string_from_utf8())
	print("Network Error: ", result[0])

#endregion
