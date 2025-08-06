extends Node

var session_cookie = ""
var username = "Admin_Username"
var password = "Admin_Password!"
var login_username = "Mahir"
var login_password = "MrMoodles123!"
var login_url = "https://dungeonsanddevelopers.cs.uct.ac.za/admin/login"
var random_q_url = "https://dungeonsanddevelopers.cs.uct.ac.za/questions/random/"
var submission_url = "https://dungeonsanddevelopers.cs.uct.ac.za/admin/submit/"
var test_code_url = "https://dungeonsanddevelopers.cs.uct.ac.za/admin/run-code"
var register_server_url = "https://dungeonsanddevelopers.cs.uct.ac.za/server/register"
var deregister_server_url = "https://dungeonsanddevelopers.cs.uct.ac.za/server/deregister"
var find_server_url = "https://dungeonsanddevelopers.cs.uct.ac.za/server/find-available?type="
var update_player_count_url = "https://dungeonsanddevelopers.cs.uct.ac.za/server/update-players"
var difficulties = ["Easy", "Medium", "Hard"]
var is_server := OS.has_feature("dedicated_server")

var request_queue = []
var current_server_request = "REGISTER"

signal question(q)
signal all_received
signal submission_result(output: String, passed: bool)
signal test_result(output: String, passed: bool)
signal server(found: bool, message: String, ip: String, port: int)
signal shutdown
signal login_completed

@onready var question_request = $HTTPRequestQuestion
@onready var submit_answer_http = $HTTPSumbitCode
@onready var test_answer_http = $HTTPTestCode
@onready var login_http = $HTTPLogin
@onready var server_http = $HTTPServer
func get_auth(questions: bool):
	var login_details = ""
	if question:
		login_details = "%s:%s" % [username, password]
	else:
		login_details = "%s:%s" % [username, password]
	var encoded_details = Marshalls.utf8_to_base64(login_details)
	var header = "Authorization: Basic %s" % encoded_details
	
	return header

func login():
	var payload = {
		"username": login_username,
		"password": login_password
	}
	var body = JSON.stringify(payload)
	var headers = ["Content-Type: application/json"]
	
	var err = login_http.request(login_url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		print("Login request failed! ", err)

func add_to_queue(url):
	request_queue.append(url)

func get_all_questions():
	var url = random_q_url + difficulties[0]
	add_to_queue(url)
	url = random_q_url + difficulties[1]
	add_to_queue(url)
	url = random_q_url + difficulties[2]
	add_to_queue(url)
	
	get_question()
	
func submit_answer(question_num: int, code: String):
	var payload = {
		"code": code
	}
	var json_payload = JSON.stringify(payload) 
	
	var url = submission_url + str(question_num)
	var headers = ["Content-Type: application/json", "Cookie: %s" % session_cookie]
	
	var err = submit_answer_http.request(url, headers, HTTPClient.METHOD_POST, json_payload)
	if err != OK:
		print("Failed to send request:", err)
	else:
		print("Request sent.")

func test_code(code: String, input):
	var payload = {
		"code": code,
		"input": input
	}
	var json_payload = JSON.stringify(payload) 
	
	var url = test_code_url
	var headers = ["Content-Type: application/json", "Cookie: %s" % session_cookie]
	
	var err = test_answer_http.request(url, headers, HTTPClient.METHOD_POST, json_payload)
	if err != OK:
		print("Failed to send request: ", err)
	else:
		print("Request sent.")

# gets a random question of a specified difficulty from the database
func get_question():
	if not is_server:
		return
	if request_queue.is_empty():
		print("All questions received")
		emit_signal("all_received")
		return
		
	var headers = [get_auth(true)]
	
	var url = request_queue.pop_front()
	var err = question_request.request(url, headers)
	if err != OK:
		print("Failed to send request:", err)

func register_server(ip: String, port: int, type: String, max_players: int):
	if not is_server:
		print("NOT SERVER! CANNOT REGISTER")
		return
	
	current_server_request = "REGISTER"
	
	var payload = {
		"ip": ip,
		"port": port,
		"type": type,
		"max_players": max_players,
		"current_players": 0
	}
	var json_payload = JSON.stringify(payload)
	
	var url = register_server_url
	var headers = ["Content-Type: application/json", "Cookie: %s" % session_cookie] 
	
	var err = server_http.request(url, headers, HTTPClient.METHOD_POST, json_payload)
	if err != OK:
		print("Failed to register server: ", err)
	else:
		print("Register request sent.")

func deregister_server(ip: String, port: int):
	if not is_server:
		return
	
	current_server_request = "DEREGISTER"
	
	var payload = {
		"ip": ip,
		"port": port,
	}
	var json_payload = JSON.stringify(payload)
	
	var url = deregister_server_url
	var headers = ["Content-Type: application/json", "Cookie: %s" % session_cookie] 
	
	var err = server_http.request(url, headers, HTTPClient.METHOD_POST, json_payload)
	if err != OK:
		print("Failed to deregister server: ", err)
	else:
		print("Deregister request sent.")

func update_player_count(ip: String, port: int, num_players: int):
	if not is_server:
		return
	
	current_server_request = "UPDATE"
	
	var payload = {
		"ip": ip,
		"port": port,
		"current_players": num_players
	}
	var json_payload = JSON.stringify(payload)
	
	var url = update_player_count_url
	var headers = ["Content-Type: application/json", "Cookie: %s" % session_cookie] 
	
	var err = server_http.request(url, headers, HTTPClient.METHOD_POST, json_payload)
	if err != OK:
		print("Failed to updated player count: ", err)
	else:
		print("Request sent.")

func find_server(type: String):
	current_server_request = "FIND"
	
	var url = find_server_url + type
	var headers = ["Content-Type: application/json", "Cookie: %s" % session_cookie] 
	
	var err = server_http.request(url, headers)
	if err != OK:
		print("Failed to find server: ", err)
	else:
		print("Request sent.")

# called when request for a question is completed
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if not is_server:
		return
		
	print("Status code:", response_code)

	var response_text := body.get_string_from_utf8()
	var json = JSON.new()
	var parse_result = json.parse(response_text)

	if parse_result == OK:
		print("JSON response:")
		#print(json.data)
		var prompt = json.data.get("prompt_md")
		var title = json.data.get("title")
		var question_num = json.data.get("question_number")
		var res = [title, prompt, question_num]
		emit_signal("question", res)
		get_question()
		
	else:
		print("Non-JSON response received:")
		print("Raw response:", response_text)

# called when a post of testing code locally is completed
func _on_test_code_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("Status Code: ", response_code)
	var response_text := body.get_string_from_utf8()
	var json = JSON.new()
	var parse_result = json.parse(response_text)
	
	if parse_result == OK:
		print("JSON response:")
		print(json.data)
		var response
		var passed = json.data.get("success")
		if passed:
			response = json.data.get("result")
		else:
			response = json.data.get("error")
		emit_signal("test_result", str(response), passed)
	else:
		print("Non-JSON response received:")
		print("Raw response:", response_text)

# called when a post of submitted code is completed
func _on_sumbit_code_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("Status code:", response_code)
	var response_text := body.get_string_from_utf8()
	var json = JSON.new()
	var parse_result = json.parse(response_text)
	
	if parse_result == OK:
		print("JSON response:")
		print(json.data)
		var response = json.data.get("message")
		var passed = json.data.get("success")
		emit_signal("submission_result", response, passed)
	else:
		print("Non-JSON response received:")
		print("Raw response:", response_text)

func _on_login_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("Login Status:", response_code)
	var response_text = body.get_string_from_utf8()
	var json = JSON.new()
	if json.parse(response_text) == OK:
		print("Login Response: ", json.data)
	else:
		print("Login Response (raw): ", response_text)
		
	# get cookie from headers
	for header in headers:
		if header.begins_with("Set-Cookie:"):
			var cookie_line = header.replace("Set-Cookie: ", "")
			session_cookie = cookie_line.split(";")[0]
			break
			
	if session_cookie != "":
		print("Session Cookie: ", session_cookie)
		#submit_code()
	else:
		print("No session cookie found... Login failed.")
		
	emit_signal("login_completed")

func _on_http_server_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	match current_server_request:
		"REGISTER":
			print("Status code:", response_code)
			var response_text := body.get_string_from_utf8()
			var json = JSON.new()
			var parse_result = json.parse(response_text)
			
			if parse_result == OK:
				print("JSON response:")
				print(json.data)
				if response_code == 201:
					var response = json.data.get("message")
					print(response)
				else:
					var response = json.data.get("error")
					print(response)
			else:
				print("Non-JSON response received:")
				print("Raw response:", response_text)
		"DEREGISTER", "UPDATE":
			print("Status code:", response_code)
			var response_text := body.get_string_from_utf8()
			var json = JSON.new()
			var parse_result = json.parse(response_text)
			
			if parse_result == OK:
				print("JSON response:")
				print(json.data)
				if response_code == 200:
					var response = json.data.get("message")
					print(response)
					emit_signal("shutdown")
				else:
					var response = json.data.get("error")
					print(response)
			else:
				print("Non-JSON response received:")
				print("Raw response:", response_text)
		"FIND":
			print("Status code:", response_code)
			var response_text := body.get_string_from_utf8()
			var json = JSON.new()
			var parse_result = json.parse(response_text)
			
			if parse_result == OK:
				print("JSON response:")
				print(json.data)
				if response_code == 200:
					var response = json.data.get("message")
					var server_data = json.data.get("server")
					print(response)
					emit_signal("server", true, response, server_data["ip"], server_data["port"])
				else:
					var response = json.data.get("error")
					print(response)
					emit_signal("server", false, response, "", 0)
			else:
				print("Non-JSON response received:")
				print("Raw response:", response_text)
